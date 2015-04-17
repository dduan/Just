PWD=$(shell pwd)
PLAYGROUND=$(PWD)/Requests.playground
BUILD_PATH=build
APP_NAME=Contents
MODULE_NAME=Requests
LIB_NAME=lib$(MODULE_NAME).dylib
LIB_PATH=$(PWD)/$(BUILD_PATH)/$(LIB_NAME)
SWIFT_MODULE_PATH=$(PWD)/$(BUILD_PATH)/$(MODULE_NAME).swiftmodule
SDK=$(shell xcrun --show-sdk-path --sdk macosx) \

main : clean
	@mkdir $(PWD)/$(BUILD_PATH)
	@swiftc \
		-sdk $(SDK) \
		-emit-library \
		-o $(LIB_PATH) \
		-Xlinker -install_name \
		-Xlinker @rpath/$(LIB_NAME) \
		-emit-module \
		-emit-module-path $(SWIFT_MODULE_PATH) \
		-module-name $(MODULE_NAME) \
		-module-link-name $(MODULE_NAME) \
		$(PLAYGROUND)/Sources/*.swift
	@swiftc $(PLAYGROUND)/$(APP_NAME).swift \
		-sdk $(SDK) \
		-o $(PWD)/$(BUILD_PATH)/$(APP_NAME) \
		-I $(PWD)/$(BUILD_PATH) \
		-L $(PWD)/$(BUILD_PATH) \
		-Xlinker -rpath \
		-Xlinker @executable_path/
	@$(PWD)/$(BUILD_PATH)/$(APP_NAME)


clean :
	@rm -rf $(PWD)/$(BUILD_PATH)
