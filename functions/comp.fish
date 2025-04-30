function comp --description "Compress files or directories"
    set -l options 'o/output=' 'l/level=' h/help v/verbose
    argparse -n compress $options -- $argv

    # Check if we're in a Chinese locale
    set -l is_chinese_env 0
    if string match -qr zh $LANG; or string match -qr zh $LC_ALL; or string match -qr zh $LC_MESSAGES
        set is_chinese_env 1
    end

    # Display usage if no args or help flag is used
    if test -z "$argv" -o -n "$_flag_help"
        if test $is_chinese_env -eq 1
            echo "\
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
如果输出文件的目录不存在，将自动创建。"
        else
            echo "\
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
If the output file's directory doesn't exist, it will be created automatically."
        end
        if test -n "$_flag_help"
            return 0
        else
            return 1
        end
    end

    # Prepare file/dir list and validate existence
    set -l input_paths
    for input in $argv
        # Check if file/dir exists
        if not test -e "$input"
            if test $is_chinese_env -eq 1
                echo "文件或目录不存在: $input"
            else
                echo "File or directory does not exist: $input"
            end
            return 1
        end

        # Get real path
        set -l abs_path (realpath $input)

        # Prevent root dir compression
        if test "$abs_path" = /
            if test $is_chinese_env -eq 1
                echo "错误: 拒绝压缩根目录 '/'"
            else
                echo "Error: Refused to compress root directory '/'"
            end
            return 1
        end

        set -a input_paths $input
    end

    # Set default compression level
    set -l level 5
    if set -q _flag_level
        # Validate compression level
        if string match -qr '^[1-9]$' $_flag_level
            set level $_flag_level
        else
            if test $is_chinese_env -eq 1
                echo "无效的压缩级别: $_flag_level (应为1-9)"
            else
                echo "Invalid compression level: $_flag_level (should be 1-9)"
            end
            return 1
        end
    end

    # Determine output filename
    set -l output_file ""
    if set -q _flag_output
        set output_file $_flag_output
    else
        # Use first input file name as base
        set -l first_input_basename (basename (realpath $input_paths[1]))

        # Default to zip format
        set output_file "$first_input_basename.zip"
    end

    # Ensure output directory exists
    set -l output_dir (dirname $output_file)
    if test "$output_dir" != "." -a ! -d $output_dir
        if set -q _flag_verbose
            if test $is_chinese_env -eq 1
                echo "创建目录: $output_dir"
            else
                echo "Creating directory: $output_dir"
            end
        end

        mkdir -p $output_dir
        if test $status -ne 0
            if test $is_chinese_env -eq 1
                echo "错误: 无法创建目录 '$output_dir'"
            else
                echo "Error: Could not create directory '$output_dir'"
            end
            return 1
        end
    end

    # Get absolute path for output file
    set output_file (realpath $output_dir)/(basename $output_file)

    # Check if output file already exists
    if test -e $output_file
        if test $is_chinese_env -eq 1
            echo "错误: 输出文件 '$output_file' 已存在。请指定不同的输出文件名。"
        else
            echo "Error: Output file '$output_file' already exists. Please specify a different output filename."
        end
        return 1
    end

    # Determine compression format from extension
    set -l format ""
    switch $output_file
        case "*.zip"
            set format zip
        case "*.rar"
            set format rar
        case "*.7z"
            set format 7z
        case "*.tar.bz2" "*.tbz2" "*.tbz" "*.tb2"
            set format "tar.bz2"
        case "*.tar.gz" "*.tgz"
            set format "tar.gz"
        case "*.tar.xz" "*.txz"
            set format "tar.xz"
        case "*.tar.lzma" "*.tlz"
            set format "tar.lzma"
        case "*.tar"
            set format tar
        case "*.bz2"
            set format bz2
        case "*.gz"
            set format gz
        case "*.xz"
            set format xz
        case "*.lzma"
            set format lzma
        case "*"
            if test $is_chinese_env -eq 1
                echo "无法从文件名确定压缩格式: $output_file"
                echo "请使用支持的扩展名。"
            else
                echo "Could not determine compression format from filename: $output_file"
                echo "Please use a supported extension."
            end
            return 1
    end

    # Check input count for single-file formats
    if contains $format bz2 gz xz lzma
        if test (count $input_paths) -gt 1
            if test $is_chinese_env -eq 1
                echo "$format 格式只能压缩单个文件，不能压缩多个文件"
            else
                echo "$format format can only compress a single file, not multiple files"
            end
            return 1
        end
        if test -d $input_paths[1]
            if test $is_chinese_env -eq 1
                echo "$format 格式只能压缩单个文件，不能压缩目录"
            else
                echo "$format format can only compress a single file, not directories"
            end
            return 1
        end
    end

    # Set verbose flag if needed
    set -l verbose_flag ""
    if set -q _flag_verbose
        set verbose_flag -v
    end

    # Get output file basename for exclusion
    set -l output_basename (basename $output_file)

    # Execute compression
    switch $format
        case zip
            # Save current directory
            set -l current_dir (pwd)

            # Process each input path
            for input in $input_paths
                set -l base_name (basename $input)

                # Compress with relative path
                if set -q _flag_verbose
                    zip -r -$level $output_file $input
                else
                    zip -q -r -$level $output_file $input
                end

                # Check for errors
                if test $status -ne 0
                    cd $current_dir
                    if test $is_chinese_env -eq 1
                        echo 压缩过程中发生错误
                    else
                        echo "Error occurred during compression"
                    end
                    return 1
                end
            end

        case rar
            if set -q _flag_verbose
                rar a -m$level $output_file $input_paths
            else
                rar a -idq -m$level $output_file $input_paths
            end

        case 7z
            # Create exclude pattern if needed
            set -l exclude_option ""
            for input in $input_paths
                if contains $output_file (realpath $input)/*; or test $output_file = (realpath $input)
                    set exclude_option "-xr!$output_basename"
                    break
                end
            end

            if set -q _flag_verbose
                7z a -mx=$level $exclude_option $output_file $input_paths
            else
                7z a -bd -mx=$level $exclude_option $output_file $input_paths
            end

        case "tar.bz2"
            set -l temp_excludes_file (mktemp)
            echo $output_basename >$temp_excludes_file

            if set -q _flag_verbose
                tar -cjvf $output_file -X $temp_excludes_file $input_paths
            else
                tar -cjf $output_file -X $temp_excludes_file $input_paths
            end

            rm -f $temp_excludes_file

        case "tar.gz"
            set -l temp_excludes_file (mktemp)
            echo $output_basename >$temp_excludes_file

            if set -q _flag_verbose
                tar -czvf $output_file -X $temp_excludes_file $input_paths
            else
                tar -czf $output_file -X $temp_excludes_file $input_paths
            end

            rm -f $temp_excludes_file

        case "tar.xz"
            set -l temp_excludes_file (mktemp)
            echo $output_basename >$temp_excludes_file

            if set -q _flag_verbose
                XZ_OPT="-$level" tar -cJvf $output_file -X $temp_excludes_file $input_paths
            else
                XZ_OPT="-$level" tar -cJf $output_file -X $temp_excludes_file $input_paths
            end

            rm -f $temp_excludes_file

        case "tar.lzma"
            set -l temp_excludes_file (mktemp)
            echo $output_basename >$temp_excludes_file

            if set -q _flag_verbose
                XZ_OPT="-$level" tar --lzma -cvf $output_file -X $temp_excludes_file $input_paths
            else
                XZ_OPT="-$level" tar --lzma -cf $output_file -X $temp_excludes_file $input_paths
            end

            rm -f $temp_excludes_file

        case tar
            set -l temp_excludes_file (mktemp)
            echo $output_basename >$temp_excludes_file

            if set -q _flag_verbose
                tar -cvf $output_file -X $temp_excludes_file $input_paths
            else
                tar -cf $output_file -X $temp_excludes_file $input_paths
            end

            rm -f $temp_excludes_file

        case bz2
            if set -q _flag_verbose
                bzip2 -$level -v -c $input_paths[1] >$output_file
            else
                bzip2 -$level -c $input_paths[1] >$output_file
            end

        case gz
            if set -q _flag_verbose
                gzip -$level -v -c $input_paths[1] >$output_file
            else
                gzip -$level -c $input_paths[1] >$output_file
            end

        case xz
            if set -q _flag_verbose
                xz -$level -v -c $input_paths[1] >$output_file
            else
                xz -$level -c $input_paths[1] >$output_file
            end

        case lzma
            if set -q _flag_verbose
                lzma -$level -v -c $input_paths[1] >$output_file
            else
                lzma -$level -c $input_paths[1] >$output_file
            end
    end

    # Check if compression succeeded
    if test $status -eq 0
        if test $is_chinese_env -eq 1
            echo "文件已压缩至: $output_file"
        else
            echo "Files compressed to: $output_file"
        end
        return 0
    else
        if test $is_chinese_env -eq 1
            echo 压缩过程中发生错误
        else
            echo "Error occurred during compression"
        end
        return 1
    end
end
