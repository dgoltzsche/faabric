include(FindGit)
find_package(Git)
include (ExternalProject)

# Protobuf/ grpc config
# See the example in the gRPC repo here:                                         
# https://github.com/grpc/grpc/blob/master/examples/cpp/helloworld/CMakeLists.txt
if(BUILD_SHARED_LIBS)
    set(Protobuf_USE_STATIC_LIBS OFF)
else()
    set(Protobuf_USE_STATIC_LIBS ON)
endif()

include(FindProtobuf)
set(protobuf_MODULE_COMPATIBLE TRUE)                                            
find_package(Protobuf REQUIRED)                                                  

message(STATUS "Using protobuf  \                                                
    ${PROTOBUF_LIBRARY} \                                                        
    ${PROTOBUF_PROTOC_LIBRARY} \                                                 
    ${PROTOBUF_PROTOC_EXECUTABLE} \                                              
")                                                                               
                                                                                 
find_package(gRPC CONFIG REQUIRED)                                               
message(STATUS "Using gRPC ${gRPC_VERSION}")                                     
                                                                                 
include_directories(${PROTOBUF_INCLUDE_DIR})                                     
                                                                                 
set(PROTOC_EXE /usr/local/bin/protoc)                                            
set(GRPC_PLUGIN /usr/local/bin/grpc_cpp_plugin)                                  

# Pistache 
ExternalProject_Add(pistache_ext
    GIT_REPOSITORY "https://github.com/pistacheio/pistache.git"
    GIT_TAG "2ef937c434810858e05d446e97acbdd6cc1a5a36"
    CMAKE_CACHE_ARGS "-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}"
    BUILD_BYPRODUCTS ${CMAKE_INSTALL_PREFIX}/lib/libpistache.so
)
ExternalProject_Get_Property(pistache_ext SOURCE_DIR)
set(PISTACHE_INCLUDE_DIR ${SOURCE_DIR}/include)
add_library(pistache SHARED IMPORTED)
add_dependencies(pistache pistache_ext)
set_target_properties(pistache
    PROPERTIES IMPORTED_LOCATION ${CMAKE_INSTALL_PREFIX}/lib/libpistache.so
)

# RapidJSON
ExternalProject_Add(rapidjson_ext
    GIT_REPOSITORY "https://github.com/Tencent/rapidjson"
    GIT_TAG "2ce91b823c8b4504b9c40f99abf00917641cef6c"
    CMAKE_ARGS "-DRAPIDJSON_BUILD_DOC=OFF \
        -DRAPIDJSON_BUILD_EXAMPLES=OFF \
        -DRAPIDJSON_BUILD_TESTS=OFF"
    CMAKE_CACHE_ARGS "-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}"
)
ExternalProject_Get_Property(rapidjson_ext SOURCE_DIR)
set(RAPIDJSON_INCLUDE_DIR ${SOURCE_DIR}/include)

# spdlog
ExternalProject_Add(spdlog_ext
    GIT_REPOSITORY "https://github.com/gabime/spdlog"
    GIT_TAG "v1.8.0"  
    CMAKE_CACHE_ARGS "-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}"
)
ExternalProject_Get_Property(spdlog_ext SOURCE_DIR)
set(SPDLOG_INCLUDE_DIR ${SOURCE_DIR}/include)

if(FAABRIC_BUILD_TESTS)
    # Catch (tests)
    ExternalProject_Add(catch_ext
        GIT_REPOSITORY "https://github.com/catchorg/Catch2"
        GIT_TAG "v2.13.2"
        CMAKE_ARGS "-DCATCH_INSTALL_DOCS=OFF \
            -DCATCH_INSTALL_EXTRAS=OFF"
        CMAKE_CACHE_ARGS "-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}"
    )
    ExternalProject_Get_Property(catch_ext SOURCE_DIR)
    include_directories(${CMAKE_INSTALL_PREFIX}/include/catch2)
endif()

