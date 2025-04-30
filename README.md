# extract.fish

`comp` - automatic compression with output format detection for [fish shell](https://github.com/fish-shell/fish-shell).

## Install

Install with [Fisher](https://github.com/jorgebucaran/fisher):

    fisher install ClanEver/comp.fish

## Usage

```console
❯ comp -h
Usage: comp [-o|--output <output_file>] [-l|--level <compression_level>] [-v|--verbose] file_or_directory...
Supported formats:
  zip     rar    7z      tar.bz2  tbz2    tbz    
  tb2     tar.gz tgz     tar.xz   txz     tar.lzma
  tlz     tar    bz2     gz       xz      lzma

Compression format is automatically determined by the output file extension.
Default compression level is 5 (1-9, 1 is fastest, 9 is highest compression).
If no output file is specified, the first input file/folder name with .zip extension will be used.
Default is silent mode, use -v or --verbose to enable detailed output.
If the output file already exists, the program will exit with an error.
If the output file's directory doesn't exist, it will be created automatically.

# 中文环境
❯ comp -h
用法: comp [-o|--output <输出文件>] [-l|--level <压缩级别>] [-v|--verbose] 文件或目录...
支持的格式:
  zip     rar    7z      tar.bz2  tbz2    tbz    
  tb2     tar.gz tgz     tar.xz   txz     tar.lzma
  tlz     tar    bz2     gz       xz      lzma

压缩格式自动根据输出文件扩展名确定。
默认压缩级别为5（1-9，1最快，9压缩率最高）。
如果未指定输出文件，将使用第一个输入文件（夹）名加.zip扩展名。
默认为静默模式，使用-v或--verbose启用详细输出。
如果输出文件已存在，程序将退出并显示错误。
如果输出文件的目录不存在，将自动创建。
```

