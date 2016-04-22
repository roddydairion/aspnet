#!/bin/bash
RED = '\033[0;31m'
NC = '\e[0m' #No color
GREEN = '\033[0;32m'
BLUE = '\033[0;34m'
YELLOW = '\033[1;33m'


clear
echo -e "\033[0;34mInstalling required depencies to run ASP.net\e[0m\n\n"
printf "\033[0;34mUpdating Mono\e[0m\n\n"
apt-get remove -y mono-complete
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo -e "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
apt-get update

echo -e "\033[0;34m Installing Mono\e[0m\n\n"
apt-get install mono-complete

echo -e "\033[1;33m Installing a few depencies\e[0m\n\n"

echo -e "\033[0;34m Installing NPM\e[0m\n\n"
apt-get install npm

echo -e "\033[0;34m Installing DNX prerequisites\e[0m\n\n"
apt-get install libunwind8 gettext libssl-dev libcurl3-dev zlib1g libicu-dev

echo -e "\033[0;34m Installing LIBuv\e[0m\n\n"
apt-get install automake libtool curl
curl -sSL https://github.com/libuv/libuv/archive/v1.4.2.tar.gz | tar zxfv - -C /usr/local/src
cd /usr/local/src/libuv-1.4.2
sh autogen.sh
./configure
make 
make install
rm -rf /usr/local/src/libuv-1.4.2 && cd ~/
ldconfig

echo -e "\033[0;34m Installing DNVM\e[0m\n\n"
apt-get install unzip
curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_BRANCH=dev sh && source ~/.dnx/dnvm/dnvm.sh
source ~/.dnx/dnvm/dnvm.sh

echo -e "\033[0;34m Installing NODE.js + Build Essential\e[0m\n\n"
apt-get remove -y nodejs build-essential
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs
apt-get install -y build-essential

echo -e "\033[0;34m Fix NuGet Feeds\e[0m\n\n"
cd ~/
mkdir NuGet
cd NuGet
cat > NuGet.config << EOF1
<?xml version="1.0" encoding="utf-8"?>
<configuration>
<packageSources>
<add key="AspNetVNext" value="https://www.myget.org/F/aspnetvnext/api/v2/" />
<add key="nuget.org" value="https://www.nuget.org/api/v3/" />
</packageSources>
<disabledPackageSources />
</configuration>
EOF1

echo -e "\033[0;34m Update DNVM + Upgrade DNX Runtime\e[0m\n\n"
dnvm update-self
dnvm install latest


echo -e "\033[0;34m Updating NPM\e[0m\n\n"
npm install -g npm@latest
npm cache clean

echo -e "\033[0;34m Installing Yeoman Generators\e[0m\n\n"
npm install -g yo grunt-cli generator-aspnet bower

echo -e "\033[0;34m Updating possible outdated Node.js\e[0m\n\n"
npm cache clean -f
npm install -g n
n stable

echo -e "\033[0;34m Getting certificates for DNU restore\e[0m\n\n"
certmgr -ssl -m https://go.microsoft.com
certmgr -ssl -m https://nugetgallery.blob.core.windows.net
certmgr -ssl -m https://nuget.org
mozroots --import --sync

echo -e "\033[0;32mTo run type 'yo aspnet'\n"
echo -e "Select Web Application\n"
echo -e "go to your folder 'cd YourAppname'\n"
echo -e "Restore NuGet Pakets by typing 'dnu restore'. Hopefully I would have convered all possible error that might occue while restoring. dnu restore will take a few minutes\n"
echo -e "Type 'dnu build'\n"
echo -e "Type 'dnx web'.\n"
echo -e "If you wish to run web in the background type 'nohup dnx web > /dev/null 2>&1 &'\n"
echo -e "If all the above runs ok then go to one of the following 'http://localhost:5000 | http://localhost:5001 | http://localhost:5004\n"
y