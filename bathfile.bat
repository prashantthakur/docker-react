@rem Copyright 2016 gRPC authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem     http://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.

@rem enter this directory
cd /d %~dp0\..\..\..

@rem TODO(jtattermusch): Kokoro has pre-installed protoc.exe in C:\Program Files\ProtoC and that directory
@rem is on PATH. To avoid picking up the older version protoc.exe, we change the path to something non-existent.
set PATH=%PATH:ProtoC=DontPickupProtoC%

cd C:\Users\prashant\source\grpc9\grpc
git submodule update --init

@rem Install into ./testinstall, but use absolute path and foward slashes
set INSTALL_DIR=C:\Users\prashant\testinstall9a

@rem Download OpenSSL-Win32 originally installed from https://slproweb.com/products/Win32OpenSSL.html
@rem powershell -Command "(New-Object Net.WebClient).DownloadFile('https://storage.googleapis.com/grpc-testing.appspot.com/OpenSSL-Win32-1_1_0g.zip', 'OpenSSL-Win32.zip')"
@rem powershell -Command "Add-Type -G"Visual Studio 16 2019" -A x64ssembly 'System.IO.Compression.FileSystem'; [System.IO.Compression.ZipFile]::ExtractToDirectory('OpenSSL-Win32.zip', '.');"

@rem set absolute path to OpenSSL with forward slashes
set OPENSSL_DIR=C:\Users\prashant\Desktop\zipdir\openssl\Lib\x64\RELEASE



cd C:\Users\prashant\source\grpc9\grpc
@rem Install absl
mkdir third_party\abseil-cpp\cmake\build
pushd third_party\abseil-cpp\cmake\build
cmake -G"Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ..\..
cmake --build . --config Release --target install || goto :error
popd

@rem Install c-G"Visual Studio 16 2019" -A x64res
mkdir third_party\cares\cares\cmake\build
pushd third_party\cares\cares\cmake\build
cmake -G"Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ..\..
cmake --build . --config Release --target install || goto :error
popd

@rem Install zlib
mkdir third_party\zlib\cmake\build
pushd third_party\zlib\cmake\build
cmake -G"Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ..\..
cmake --build . --config Release --target install || goto :error
popd

cd C:\Users\prashant\source\repos\protos
@rem Install protobuf
@rem mkdir protobuf\cmake\build
pushd protobuf\cmake\build
cmake -G"Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% -DZLIB_ROOT=%INSTALL_DIR% -Dprotobuf_MSVC_STATIC_RUNTIME=OFF -Dprotobuf_BUILD_TESTS=OFF ..
cmake --build . --config Release --target install || goto :error
popd


cd C:\Users\prashant\source\grpc9\grpc


@rem Just before installing gRPC, wipe out contents of all the submodules to simulate
@rem a standalone build from an archive
git submodule deinit --force

@rem Install gRPC
mkdir cmake\build
pushd cmake\build
cmake -G"Visual Studio 16 2019" -A x64 ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ^
  -DOPENSSL_ROOT_DIR=%OPENSSL_DIR% ^
  -DZLIB_ROOT=%INSTALL_DIR% ^
  -DgRPC_INSTALL=ON ^
  -DgRPC_BUILD_TESTS=OFF ^
  -DgRPC_ABSL_PROVIDER=package ^
  -DgRPC_CARES_PROVIDER=package ^
  -DgRPC_PROTOBUF_PROVIDER=package ^
  -DgRPC_SSL_PROVIDER=package ^
  -DgRPC_ZLIB_PROVIDER=package ^
  ../.. || goto :error
cmake --build . --config Release --target install || goto :error
popd

@rem Build helloworld example using cmake
mkdir examples\cpp\helloworld\cmake\build
pushd examples\cpp\helloworld\cmake\build
cmake -G"Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% -DOPENSSL_ROOT_DIR=%OPENSSL_DIR% -DZLIB_ROOT=%INSTALL_DIR% ../.. || goto :error
cmake --build . --config Release --target install || goto :error
popd

goto :EOF
cmake -G"Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=C:\Users\prashant\testinstall9a -DOPENSSL_ROOT_DIR=C:\Users\prashant\Desktop\zipdir\openssl\Lib\x64\RELEASE -DZLIB_ROOT=C:\Users\prashant\testinstall9a ..
:error
echo Failed!
exit /b %errorlevel%

void write_text_to_log_file( const std::string &text )
{
    std::ofstream log_file(
        "log_file.txt", std::ios_base::out | std::ios_base::app );
    log_file << text << std::end;
}
