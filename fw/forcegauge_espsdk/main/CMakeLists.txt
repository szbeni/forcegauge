set(EXTRA_COMPONENT_DIRS {CMAKE_CURRENT_SOURCE_DIR}/libs/esp-idf-lib/components/i2cdev)

idf_component_register(SRCS "main.c" "mytask.cpp" "ssd1306/ssd1306_test.c" "ssd1306/ssd1306.c" "ssd1306/ssd1306_i2c.c" "ssd1306/software_i2c.c"
                    INCLUDE_DIRS ".")


# include($ENV{IDF_PATH}/tools/cmake/project.cmake)
# project(my-esp-project)