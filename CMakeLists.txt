cmake_minimum_required(VERSION 3.16)

project(file_modifier VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

qt6_add_resources(RESOURCES_FILES
    qml/resources/resources.qrc
)

# Чтобы не добавлять файлы самим, просто укажем к ним дирректории
file(GLOB_RECURSE SOURCE_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
)
file(GLOB_RECURSE HEADER_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/include/*.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp
)

# Content of downloaded design from Figma to Qt or similar
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/importedcontent/CMakeLists.txt")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/importedcontent)
endif()

qt_add_executable(appfile_modifier
    ${SOURCE_FILES}
    ${HEADER_FILES}
    ${RESOURCES_FILES}
)

target_include_directories(appfile_modifier
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

set_source_files_properties(qml/theme/Theme.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(appfile_modifier
    URI file_modifier
    RESOURCE_PREFIX "/qt/qml"
    QML_FILES
        qml/Main.qml
        # components
        qml/components/MyButton.qml
        qml/components/MyTextField.qml
        qml/components/MyCheckBox.qml
        qml/components/MyProgressBar.qml
        # views
        # singleton theme
        qml/theme/Theme.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appfile_modifier PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appfile_modifier
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appfile_modifier
    PRIVATE Qt6::Quick
)

install(TARGETS appfile_modifier
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
