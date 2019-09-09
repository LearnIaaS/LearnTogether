# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The program to use to edit the cache.
CMAKE_EDIT_COMMAND = /usr/bin/ccmake

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /root/incubator-brpc/example/multi_threaded_echo_c++

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /root/incubator-brpc/example/multi_threaded_echo_c++/build

# Include any dependencies generated for this target.
include CMakeFiles/multi_threaded_echo_server.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/multi_threaded_echo_server.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/multi_threaded_echo_server.dir/flags.make

echo.pb.cc: ../echo.proto
	$(CMAKE_COMMAND) -E cmake_progress_report /root/incubator-brpc/example/multi_threaded_echo_c++/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold "Running C++ protocol buffer compiler on echo.proto"
	/usr/bin/protoc --cpp_out /root/incubator-brpc/example/multi_threaded_echo_c++/build -I /root/incubator-brpc/example/multi_threaded_echo_c++ /root/incubator-brpc/example/multi_threaded_echo_c++/echo.proto

echo.pb.h: echo.pb.cc

CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o: CMakeFiles/multi_threaded_echo_server.dir/flags.make
CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o: ../server.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /root/incubator-brpc/example/multi_threaded_echo_c++/build/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o -c /root/incubator-brpc/example/multi_threaded_echo_c++/server.cpp

CMakeFiles/multi_threaded_echo_server.dir/server.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/multi_threaded_echo_server.dir/server.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /root/incubator-brpc/example/multi_threaded_echo_c++/server.cpp > CMakeFiles/multi_threaded_echo_server.dir/server.cpp.i

CMakeFiles/multi_threaded_echo_server.dir/server.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/multi_threaded_echo_server.dir/server.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /root/incubator-brpc/example/multi_threaded_echo_c++/server.cpp -o CMakeFiles/multi_threaded_echo_server.dir/server.cpp.s

CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o.requires:
.PHONY : CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o.requires

CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o.provides: CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o.requires
	$(MAKE) -f CMakeFiles/multi_threaded_echo_server.dir/build.make CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o.provides.build
.PHONY : CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o.provides

CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o.provides.build: CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o

CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o: CMakeFiles/multi_threaded_echo_server.dir/flags.make
CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o: echo.pb.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /root/incubator-brpc/example/multi_threaded_echo_c++/build/CMakeFiles $(CMAKE_PROGRESS_3)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o -c /root/incubator-brpc/example/multi_threaded_echo_c++/build/echo.pb.cc

CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /root/incubator-brpc/example/multi_threaded_echo_c++/build/echo.pb.cc > CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.i

CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /root/incubator-brpc/example/multi_threaded_echo_c++/build/echo.pb.cc -o CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.s

CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o.requires:
.PHONY : CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o.requires

CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o.provides: CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o.requires
	$(MAKE) -f CMakeFiles/multi_threaded_echo_server.dir/build.make CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o.provides.build
.PHONY : CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o.provides

CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o.provides.build: CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o

# Object files for target multi_threaded_echo_server
multi_threaded_echo_server_OBJECTS = \
"CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o" \
"CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o"

# External object files for target multi_threaded_echo_server
multi_threaded_echo_server_EXTERNAL_OBJECTS =

multi_threaded_echo_server: CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o
multi_threaded_echo_server: CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o
multi_threaded_echo_server: CMakeFiles/multi_threaded_echo_server.dir/build.make
multi_threaded_echo_server: /root/incubator-brpc/output/lib/libbrpc.a
multi_threaded_echo_server: /usr/lib64/libgflags.so
multi_threaded_echo_server: /usr/lib64/libprotobuf.so
multi_threaded_echo_server: /usr/lib64/libleveldb.so
multi_threaded_echo_server: /usr/lib64/libssl.so
multi_threaded_echo_server: /usr/lib64/libcrypto.so
multi_threaded_echo_server: /usr/lib64/libgtest.so
multi_threaded_echo_server: /usr/lib64/libtcmalloc_and_profiler.so
multi_threaded_echo_server: /usr/lib64/libgflags.so
multi_threaded_echo_server: /usr/lib64/libprotobuf.so
multi_threaded_echo_server: /usr/lib64/libleveldb.so
multi_threaded_echo_server: /usr/lib64/libssl.so
multi_threaded_echo_server: /usr/lib64/libcrypto.so
multi_threaded_echo_server: /usr/lib64/libgtest.so
multi_threaded_echo_server: /usr/lib64/libtcmalloc_and_profiler.so
multi_threaded_echo_server: CMakeFiles/multi_threaded_echo_server.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable multi_threaded_echo_server"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/multi_threaded_echo_server.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/multi_threaded_echo_server.dir/build: multi_threaded_echo_server
.PHONY : CMakeFiles/multi_threaded_echo_server.dir/build

CMakeFiles/multi_threaded_echo_server.dir/requires: CMakeFiles/multi_threaded_echo_server.dir/server.cpp.o.requires
CMakeFiles/multi_threaded_echo_server.dir/requires: CMakeFiles/multi_threaded_echo_server.dir/echo.pb.cc.o.requires
.PHONY : CMakeFiles/multi_threaded_echo_server.dir/requires

CMakeFiles/multi_threaded_echo_server.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/multi_threaded_echo_server.dir/cmake_clean.cmake
.PHONY : CMakeFiles/multi_threaded_echo_server.dir/clean

CMakeFiles/multi_threaded_echo_server.dir/depend: echo.pb.cc
CMakeFiles/multi_threaded_echo_server.dir/depend: echo.pb.h
	cd /root/incubator-brpc/example/multi_threaded_echo_c++/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /root/incubator-brpc/example/multi_threaded_echo_c++ /root/incubator-brpc/example/multi_threaded_echo_c++ /root/incubator-brpc/example/multi_threaded_echo_c++/build /root/incubator-brpc/example/multi_threaded_echo_c++/build /root/incubator-brpc/example/multi_threaded_echo_c++/build/CMakeFiles/multi_threaded_echo_server.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/multi_threaded_echo_server.dir/depend
