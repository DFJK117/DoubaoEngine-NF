package server.net;

#if sys
import general.backend.Paths;
import haxe.crypto.Sha256;
import haxe.io.Bytes;
import haxe.io.Eof;
import sys.FileSystem;
import sys.io.File;
import sys.net.Host;
import sys.net.Socket;
#end
import StringTools;

/**
 * 模组分发（二期）。
 *
 * 不依赖 zip 库，用自定义容器 NFMOD1（全部小端）：
 *   'NFMOD1' + 0x00 | u32 文件数
 *   [ u16 名长 | 名(utf8) | u32 大小低 | u32 大小高(=0) | 内容 ] × N
 *   u32 文件数（尾部校验）
 *
 * 为什么不用 zip：Haxe std 没有可用的 zip 写入器；自己定义容器反而更简单、
 * 校验点也更多（magic / 计数 / 尾部 / 每文件大小 / 路径白名单）。
 *
 * 安全约束（写死，调用方改不了）：
 *   - 模组名不允许 / \ : 和 ..，不允许点开头
 *   - 容器内文件路径不允许 .. 、盘符、反斜杠、绝对路径
 *   - 解包目标永远是 <mods>/<模组名>/，路径由 _safeRel + ensureDir 限定
 *   - 只覆盖同名文件，**从不删除**已有文件（避免误删玩家自己的东西）
 */
class ModTransfer
{
	public static inline var MAGIC:String = 'NFMOD1';

	/** 打包上限：服务器侧 sha256 校验 + 本地哈希都要整包进内存 */
	public static inline var MAX_PACK_BYTES:Int = 192 * 1024 * 1024;

	static inline var CHUNK:Int = 1024 * 1024;

	/** 状态输出（NetMenuState 会接到聊天/状态栏上） */
	public static var onLog:String->Void = null;

	public static var onProgress:Float->Void = null;

	public static function log(s:String):Void
		if (onLog != null)
			onLog(s);

	public static function fmtMB(n:Float):String
	{
		if (n >= 1048576)
			return Math.round(n / 1048576 * 10) / 10 + 'MB';
		return Math.round(n / 1024) + 'KB';
	}

	static function modsRoot():String
	{
		#if MODS_ALLOWED
		return Paths.mods();
		#else
		return 'mods/';
		#end
	}

	static function toHex(b:Bytes):String
	{
		var s:String = '';
		for (i in 0...b.length)
			s += StringTools.hex(b.get(i), 2);
		return s.toLowerCase();
	}

	static function hashFile(path:String):String
	{
		try
		{
			return toHex(Sha256.make(File.getBytes(path)));
		}
		catch (e:Dynamic)
		{
			log('哈希失败: ' + e);
			return '';
		}
	}

	// ------------------------------------------------------------ 名称与路径
	public static function safeModName(n:String):Bool
	{
		if (n == null || n.length == 0 || n.length > 64)
			return false;
		if (n.charAt(0) == '.' || n.indexOf('..') >= 0)
			return false;
		if (n.indexOf('/') >= 0 || n.indexOf('\\') >= 0 || n.indexOf(':') >= 0)
			return false;
		return true;
	}

	static function _safeRel(n:String):Bool
	{
		if (n == null || n.length == 0 || n.length > 512)
			return false;
		if (n.indexOf('\0') >= 0 || n.indexOf('..') >= 0 || n.indexOf(':') >= 0)
			return false;
		if (n.indexOf('\\') >= 0)
			return false;
		if (StringTools.startsWith(n, '/') || StringTools.startsWith(n, '\\'))
			return false;
		return true;
	}

	static function ensureDir(path:String):Void
	{
		var parts:Array<String> = path.split('/');
		parts.pop(); // 去掉文件名
		var cur:String = '';
		for (seg in parts)
		{
			if (seg.length == 0)
				continue;
			cur += seg + '/';
			if (!FileSystem.exists(cur))
				FileSystem.createDirectory(cur);
		}
	}

	static function deleteFile(path:String):Void
	{
		try
			if (FileSystem.exists(path))
				FileSystem.deleteFile(path)
		catch (e:Dynamic) {}
	}

	// ------------------------------------------------------------ 歌 → 模组
	/**
	 * 反查：这首歌在哪个 mod 里。
	 * 返回 '' 表示官方本体（游戏自带），不需要分发。
	 * 判定：本体歌在 assets/songs/<歌>；mod 歌在 mods/<名>/songs/<歌>。
	 */
	public static function findModForSong(song:String):String
	{
		#if sys
		var sp:String = song;
		try
		{
			sp = Paths.formatToSongPath(song);
		}
		catch (e:Dynamic)
		{
			sp = StringTools.replace(song.toLowerCase(), ' ', '-');
		}
		if (sp.length == 0)
			return '';
		var official:Bool = false;
		try
		{
			official = FileSystem.exists('assets/songs/' + sp);
		}
		catch (e:Dynamic) {}
		if (official)
			return '';
		try
		{
			var root:String = modsRoot();
			if (root == null || root.length == 0 || !FileSystem.exists(root))
				return '';
			var dirs:Array<String> = FileSystem.readDirectory(root);
			dirs.sort(function(a, b)
				return Reflect.compare(a, b));
			for (d in dirs)
			{
				if (StringTools.startsWith(d, '.'))
					continue;
				var p:String = root + d;
				if (!FileSystem.isDirectory(p))
					continue;
				if (FileSystem.exists(p + '/songs/' + sp))
					return d;
			}
		}
		catch (e:Dynamic) {}
		#end
		return '';
	}

	// ------------------------------------------------------------ 打包 / 解包
	static function collect(base:String, rel:String, out:Array<String>):Void
	{
		var p:String = base + (rel.length > 0 ? '/' + rel : '');
		var names:Array<String> = FileSystem.readDirectory(p);
		names.sort(function(a, b)
			return Reflect.compare(a, b));
		for (name in names)
		{
			if (StringTools.startsWith(name, '.'))
				continue;
			var sub:String = rel.length > 0 ? rel + '/' + name : name;
			var full:String = base + '/' + sub;
			if (FileSystem.isDirectory(full))
				collect(base, sub, out);
			else
				out.push(sub);
		}
	}

	static inline function w16(o:sys.io.FileOutput, v:Int):Void
	{
		o.writeByte(v & 0xFF);
		o.writeByte((v >> 8) & 0xFF);
	}

	static inline function w32(o:sys.io.FileOutput, v:Int):Void
	{
		o.writeByte(v & 0xFF);
		o.writeByte((v >> 8) & 0xFF);
		o.writeByte((v >> 16) & 0xFF);
		o.writeByte((v >>> 24) & 0xFF);
	}

	static inline function r16(i:sys.io.FileInput):Int
	{
		var b0:Int = i.readByte();
		var b1:Int = i.readByte();
		return b0 | (b1 << 8);
	}

	static inline function r32(i:sys.io.FileInput):Int
	{
		var b0:Int = i.readByte();
		var b1:Int = i.readByte();
		var b2:Int = i.readByte();
		var b3:Int = i.readByte();
		return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
	}

	static function writeMagic(o:sys.io.FileOutput):Void
	{
		for (k in 0...MAGIC.length)
			o.writeByte(MAGIC.charCodeAt(k));
		o.writeByte(0);
	}

	static function readMagic(i:sys.io.FileInput):Bool
	{
		for (k in 0...MAGIC.length)
			if (i.readByte() != MAGIC.charCodeAt(k))
				return false;
		return i.readByte() == 0;
	}

	/** 把 mods/<modDir> 打包成 NFMOD1 容器。失败返回 null。 */
	public static function packMod(modDir:String, outPath:String):Null<{size:Int, sha:String, files:Int}>
	{
		#if sys
		if (!safeModName(modDir))
		{
			log('模组名非法: ' + modDir);
			return null;
		}
		var base:String = modsRoot() + modDir;
		if (!FileSystem.exists(base) || !FileSystem.isDirectory(base))
		{
			log('模组目录不存在: ' + base);
			return null;
		}
		var files:Array<String> = [];
		collect(base, '', files);
		if (files.length <= 0)
		{
			log('模组目录是空的');
			return null;
		}
		files.sort(function(a, b)
			return Reflect.compare(a, b));
		var out = File.write(outPath, true);
		var count:Int = 0;
		try
		{
			writeMagic(out);
			w32(out, files.length);
			for (rel in files)
			{
				var data:Bytes = File.getBytes(base + '/' + rel);
				if (data.length > 0x7FFFFFF0)
					throw '单文件超过 2GB: ' + rel;
				var nb:Bytes = Bytes.ofString(rel);
				w16(out, nb.length);
				out.write(nb);
				w32(out, data.length);
				w32(out, 0);
				out.write(data);
				count++;
				if (count % 24 == 0)
					log('打包中 ' + count + '/' + files.length);
			}
			w32(out, files.length);
		}
		catch (e:Dynamic)
		{
			try
				out.close()
			catch (e2:Dynamic) {}
			log('打包失败: ' + e);
			return null;
		}
		out.close();
		var size:Int = FileSystem.stat(outPath).size;
		if (size > MAX_PACK_BYTES)
		{
			log('模组包 ' + fmtMB(size) + ' 超过上限 ' + fmtMB(MAX_PACK_BYTES) + '，暂不支持自动分发');
			return null;
		}
		var sha:String = hashFile(outPath);
		if (sha.length != 64)
			return null;
		log('打包完成: ' + count + ' 文件 ' + fmtMB(size) + ' sha=' + sha.substr(0, 8) + '...');
		return {size: size, sha: sha, files: count};
		#end
		return null;
	}

	/** 只读校验容器结构（不解包）。 */
	public static function validateContainer(nfPath:String):Bool
	{
		#if sys
		try
		{
			var i = File.read(nfPath, true);
			var ok:Bool = false;
			try
			{
				if (!readMagic(i))
					throw 'not NFMOD';
				var n:Int = r32(i);
				if (n <= 0 || n > 200000)
					throw 'bad count';
				for (k in 0...n)
				{
					var nl:Int = r16(i);
					var nm:String = i.read(nl).toString();
					var lo:Int = r32(i);
					var hi:Int = r32(i);
					if (hi != 0)
						throw 'file too large';
					if (!_safeRel(nm))
						throw 'bad path ' + nm;
					var left:Int = lo;
					var buf:Bytes = Bytes.alloc(CHUNK);
					while (left > 0)
					{
						var k2:Int = left < CHUNK ? left : CHUNK;
						var got:Int = i.readBytes(buf, 0, k2);
						if (got <= 0)
							throw 'eof';
						left -= got;
					}
				}
				ok = r32(i) == n;
			}
			catch (e:Eof)
			{
				ok = false;
			}
			i.close();
			return ok;
		}
		catch (e:Dynamic)
		{
			return false;
		}
		#end
		return false;
	}

	/** 解包到 mods/<modName>/，只覆盖同名文件、从不删除。 */
	public static function unpackMod(nfPath:String, modName:String):Bool
	{
		#if sys
		if (!safeModName(modName))
		{
			log('模组名非法: ' + modName);
			return false;
		}
		if (!validateContainer(nfPath))
		{
			log('容器校验失败');
			return false;
		}
		var target:String = modsRoot() + modName;
		var i = File.read(nfPath, true);
		var count:Int = 0;
		var ok:Bool = true;
		try
		{
			if (!readMagic(i))
				throw 'not NFMOD';
			var n:Int = r32(i);
			for (k in 0...n)
			{
				var nl:Int = r16(i);
				var nm:String = i.read(nl).toString();
				var lo:Int = r32(i);
				var hi:Int = r32(i);
				if (hi != 0)
					throw 'file too large';
				if (!_safeRel(nm))
					throw 'bad path ' + nm;
				var dst:String = target + '/' + nm;
				ensureDir(dst);
				var f = File.write(dst, true);
				var left:Int = lo;
				var buf:Bytes = Bytes.alloc(CHUNK);
				while (left > 0)
				{
					var k2:Int = left < CHUNK ? left : CHUNK;
					var got:Int = i.readBytes(buf, 0, k2);
					f.writeBytes(buf, 0, got);
					left -= got;
				}
				f.close();
				count++;
			}
			if (r32(i) != n)
			{
				ok = false;
				log('尾部校验不一致');
			}
		}
		catch (e:Eof)
		{
			ok = false;
			log('文件提前结束');
		}
		catch (e:Dynamic)
		{
			ok = false;
			log('解包失败: ' + e);
		}
		i.close();
		log('解包完成 ' + count + ' 文件 -> ' + target);
		return ok;
		#end
		return false;
	}

	public static function deleteFile(path:String):Void
	{
		#if sys
		try
			if (FileSystem.exists(path))
				FileSystem.deleteFile(path)
		catch (e:Dynamic) {}
		#end
	}

	/** 传输用的临时文件路径（放在 mods/.nfmod_cache/ 下） */
	public static function tempPath():String
	{
		#if sys
		var root:String = modsRoot();
		try
		{
			if (!FileSystem.exists(root))
				FileSystem.createDirectory(root);
		}
		catch (e:Dynamic) {}
		var d:String = root + '.nfmod_cache';
		try
		{
			if (!FileSystem.exists(d))
				FileSystem.createDirectory(d);
		}
		catch (e:Dynamic) {}
		return d + '/pack_' + Std.string(Math.round(Math.random() * 899999 + 100000)) + '.nfmod';
		#end
		return 'pack.nfmod';
	}

	// ------------------------------------------------------------ HTTP 传输
	/** 房主上传模组包。返回是否 200。onProg 参数 0..1 */
	public static function uploadMod(host:String, port:Int, uri:String, filePath:String, size:Int,
			?onProg:Float->Void):Bool
	{
		#if sys
		if (size <= 0 || !FileSystem.exists(filePath))
			return false;
		var s:Socket = null;
		try
		{
			s = new Socket();
			s.setFastSend(true);
			s.connect(new Host(host), port);
			s.output.writeString('PUT ' + uri + ' HTTP/1.0\r\nHost: ' + host
				+ '\r\nContent-Length: ' + size
				+ '\r\nContent-Type: application/octet-stream\r\nUser-Agent: NFE-ModTransfer\r\nConnection: close\r\n\r\n');
			s.output.flush();
			var f = File.read(filePath, true);
			var buf:Bytes = Bytes.alloc(CHUNK);
			var sent:Int = 0;
			while (sent < size)
			{
				var k:Int = size - sent < CHUNK ? size - sent : CHUNK;
				var got:Int = f.readBytes(buf, 0, k);
				if (got <= 0)
					break;
				s.output.writeBytes(buf, 0, got);
				sent += got;
				if (onProg != null)
					onProg(sent / size);
			}
			f.close();
			// 读响应直到连接关闭（HTTP/1.0）
			var resp:String = '';
			try
			{
				while (true)
					resp += s.input.readLine() + '\n';
			}
			catch (e:Eof) {}
			s.close();
			s = null;
			var ok:Bool = resp.indexOf(' 200 ') >= 0;
			log(ok ? '模组上传完成' : '模组上传被拒: ' + resp.substr(0, 40));
			return ok;
		}
		catch (e:Dynamic)
		{
			log('上传出错: ' + e);
			if (s != null)
				try
					s.close()
				catch (e2:Dynamic) {}
			return false;
		}
		#end
		return false;
	}

	/** 客机下载模组包。校验字节数；onProg 参数 0..1 */
	public static function downloadMod(host:String, port:Int, uri:String, outPath:String, expectSize:Int,
			?onProg:Float->Void):Bool
	{
		#if sys
		var s:Socket = null;
		try
		{
			s = new Socket();
			s.connect(new Host(host), port);
			s.output.writeString('GET ' + uri + ' HTTP/1.0\r\nHost: ' + host
				+ '\r\nUser-Agent: NFE-ModTransfer\r\nConnection: close\r\n\r\n');
			s.output.flush();
			var status:String = StringTools.trim(s.input.readLine());
			if (status.indexOf(' 200 ') < 0)
			{
				log('下载被拒: ' + status);
				s.close();
				s = null;
				return false;
			}
			var cl:Int = expectSize;
			while (true)
			{
				var h:String = StringTools.trim(s.input.readLine());
				if (h.length == 0)
					break;
				var c:Int = h.indexOf(':');
				if (c > 0 && h.substr(0, c).toLowerCase() == 'content-length')
				{
					var v:Null<Int> = Std.parseInt(StringTools.trim(h.substr(c + 1)));
					if (v != null && v > 0)
						cl = v;
				}
			}
			var f = File.write(outPath, true);
			var buf:Bytes = Bytes.alloc(CHUNK);
			var got:Int = 0;
			try
			{
				while (true)
				{
					var n:Int = s.input.readBytes(buf, 0, buf.length);
					if (n <= 0)
						break;
					f.writeBytes(buf, 0, n);
					got += n;
					if (onProg != null && cl > 0)
						onProg(got / cl);
				}
			}
			catch (e:Eof) {}
			f.close();
			s.close();
			s = null;
			var ok:Bool = cl <= 0 ? got > 0 : got == cl;
			log(ok ? ('下载完成 ' + fmtMB(got)) : ('下载数量不符: ' + got + '/' + cl));
			return ok;
		}
		catch (e:Dynamic)
		{
			log('下载出错: ' + e);
			if (s != null)
				try
					s.close()
				catch (e2:Dynamic) {}
			return false;
		}
		#end
		return false;
	}
}
