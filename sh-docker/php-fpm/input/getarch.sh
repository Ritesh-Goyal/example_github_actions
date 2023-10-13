architecture=""
case $(uname -m) in
    i386)   architecture="i386" ;;
    i686)   architecture="i386" ;;
    x86_64) architecture="amd64" ;;
    amd64) architecture="amd64" ;;
    arm64)  architecture="arm64" ;;
    aarch64)  architecture="arm64" ;;
esac
echo $architecture;