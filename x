








DEPENDENCIES:

amd64 architicture, install homebrew: I found that putting <arch -x86_64 > before the official homebrew install command gets the job done ;)

echo "🍺 Installing Homebrew dependencies..."
echo "base tools"
brew install python wget git make xerces-c
echo "Build utilities"
brew install cmake ninja pkgconf
echo "graphics requirements"
brew install qt@5 libx11
brew install --cask xquartz
echo "root stuff"
brew install cfitsio davix fftw freetype ftgl gcc giflib gl2ps glew \
             graphviz gsl jpeg-turbo libpng libtiff lz4 mariadb-connector-c \
             nlohmann-json numpy openblas openssl pcre pcre2 python sqlite \
             tbb xrootd xxhash xz zstd

# Update and cleanup
brew update && brew upgrade && brew autoremove && brew cleanup && brew doctor
——————————————
BUILD:

echo "📂 Setting up paths..."
ROOT_SRC=~/root
ROOT_BUILD=~/root/build
ROOT_INSTALL=~/root-x11

echo "📁 Cloning ROOT source..."
git clone https://github.com/root-project/root.git "$ROOT_SRC"
cd "$ROOT_SRC" || exit 1
git checkout v6-36-00

echo "📂 Creating build directory..."
mkdir -p "$ROOT_BUILD"
cd "$ROOT_BUILD" || exit 1

echo "🧹 Cleaning CMake cache if it exists..."
rm -rf CMakeCache.txt CMakeFiles/

echo "⚙️ Configuring ROOT..."
CFLAGS="-I/usr/local/include"
CXXFLAGS="-I/usr/local/include"
LDFLAGS="-L/usr/local/lib"

env CFLAGS="$CFLAGS" \
    CXXFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
    arch -x86_64 cmake .. \
      -DCMAKE_INSTALL_PREFIX="$ROOT_INSTALL" \
      -Dx11=ON \
      -Dopengl=ON \
      -Droofit=ON \
      -Dtmva=ON \
      -DCMAKE_CXX_STANDARD=17

echo "🔍 Verifying zstd detection..."
grep ZSTD CMakeCache.txt || echo "⚠️ zstd not detected properly."

echo "🛠️ Building ROOT..."
arch -x86_64 make -j$(sysctl -n hw.logicalcpu)
arch -x86_64 make install
——————————————
.zshrc:

echo "📦 Adding environment setup to ~/.zshrc..."
cat <<EOF >> ~/.zshrc

# HOMEBREW
eval "\$(/usr/local/bin/brew shellenv)"  

# ROOT X11-enabled build
export ROOTSYS=$ROOT_INSTALL
export PATH="\$ROOTSYS/bin:\$PATH"
export LD_LIBRARY_PATH="\$ROOTSYS/lib:\$LD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="\$ROOTSYS/lib:\$DYLD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="\$ROOTSYS:\$CMAKE_PREFIX_PATH"
export CPATH="\$ROOTSYS/include:\$CPATH"
export DISPLAY=:0
EOF
——————————————
EXAMPLE:

# Build [Bacon2Data](https://github.com/liebercanis/bacon2Data/tree/runTwo) Example

### Clone
git clone --branch runTwo https://github.com/liebercanis/bacon2Data.git

cd bacon2Data && git pull

### clean the clone up when needed
git fetch origin && git reset --hard origin/runTwo && git clean -fdx 

### Create symlink
cd bobj

 << on mac arm64>>

ln -s /opt/homebrew/opt/root/etc/root/Makefile.arch .

 << on mac amd64>>
 
ln -s /usr/local/opt/root/etc/root/Makefile.arch .

 << on linux >>

ln -s /snap/root-framework/current/usr/local/etc/Makefile.arch .

### Build
>
>cd bobj && make clean; make
>
>cd ../compiled && make clean; make

### Create Data Directories

<< on mac >> 
cd compiled
mkdir caenData
mkdir rootData  

<< on linux >> 
cd compiled
ln -s /mnt/Data2/BaconRun4Data/rootData/ rootData
ln -s /mnt/Data2/BaconRun4Data/caenDataTensor/ caenData
cd bacon2Data
ln -s /mnt/Data2/BaconRun4Data/rootData/ rootData
ln -s /mnt/Data2/BaconRun4Data/caenDataTensor/ caenData
### Run the Excutables in bacon2Data/compiled/

 on mac:
btbSim <event number>
root <btbSimq0000-00-00-00-00-1000000.root>

cp <btbSimq0000-00-00-00-00-1000000.root> rootData/
anacg <btbSimq0000-00-00-00-00-1000000.root> 1000000
cd caenData
root <anaCRun-btbSim-0000-00-00-00-00-1000000-0.root>

postAna -> in gain.C change summary name (line 288)

on linux:
cd bacon2Data
nohup ./anacDir.py 00_00_0000 >& anacDir00_00_0000.log &
top
cd caenData
root <anaCRun-run-00_00_0000-file_0-0.root>

postAna -> in gain.C change summary name (line 288)





BACONMONITOR
On mac:
 xhost +SI:localuser:root 
On daq (via ssh):
ln -s /home/bacon/BaconMonitor/BaconMonitor2_tensor.py /home/Tensor/BaconMonitor2_tensor.py
sudo visudo
	Tensor ALL=(ALL) NOPASSWD: SETENV: /usr/bin/python3 /home/Tensor/BaconMonitor2_tensor.py

