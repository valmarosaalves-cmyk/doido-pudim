SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

haxelib --global install hxpkg

while true; do
    read -p "Would you like to install these libraries globally (might interfere with other mods) [y/n] ? " i1
    case $i1 in
        [Yy]* ) haxelib --global run hxpkg install --force --global
                break;;
        [Nn]* ) haxelib --global run hxpkg install --force
                break;;
    esac
done

while true; do
    read -p "All versions set!! Would you like to build the game now [y/n] ? " i3
    case $i3 in
        [Yy]* ) haxelib run lime test linux;
                break;;
        [Nn]* ) quit;;
    esac
done