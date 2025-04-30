complete -c comp -e

set -l is_chinese_env 0
if string match -qr zh $LANG; or string match -qr zh $LC_ALL; or string match -qr zh $LC_MESSAGES
    set is_chinese_env 1
end

if test $is_chinese_env -eq 1
    complete -c comp -s o -l output -d 指定输出文件 -r
    complete -c comp -s l -l level -d 压缩等级 -r -f -a "1\t'最快' 2\t'' 3\t'' 4\t'' 5\t'默认' 6\t'' 7\t'' 8\t'' 9\t'最高压缩'"
    complete -c comp -s v -l verbose -d 启用详细输出
    complete -c comp -s h -l help -d 显示帮助信息
    complete -c comp -a "(__fish_complete_path)"
else
    complete -c comp -s o -l output -d "specify output file" -r
    complete -c comp -s l -l level -d 'compress level' -r -f -a "1\t'fastest' 2\t'' 3\t'' 4\t'' 5\t'default' 6\t'' 7\t'' 8\t'' 9\t'highest compression'"
    complete -c comp -s v -l verbose -d "enable verbose output"
    complete -c comp -s h -l help -d "show help message"
    complete -c comp -a "(__fish_complete_path)"
end
