# -------------------------------------------------
# Project created by QtCreator 2009-12-07T20:35:20
# -------------------------------------------------
QT += network \
	opengl \
	webkit \
	xml

system(make -C ./compiler)

TARGET = "nesicide"

# if the user didnt set cxxflags and libs then use defaults
###########################################################

isEmpty (NESICIDE_LIBS) {
	NESICIDE_LIBS = -lnesicide-emulator
}

isEmpty (SDL_CXXFLAGS) {
	SDL_CXXFLAGS = $$system(sdl-config --cflags)
}

isEmpty (SDL_LIBS) {
        SDL_LIBS = $$system(sdl-config --libs)
}

# lua provides lua.pc, but several distros renamed it for slotting ( installing multiple versions )

isEmpty (LUA_CXXFLAGS) {
        LUA_CXXFLAGS = $$system(pkg-config --silence-errors --cflags lua)
}

isEmpty (LUA_CXXFLAGS) {
        LUA_CXXFLAGS = $$system(pkg-config --silence-errors --cflags lua5.1)
}

isEmpty (LUA_CXXFLAGS) {
	LUA_CXXFLAGS = $$system(pkg-config --silence-errors --cflags lua-5.1)
}

isEmpty (LUA_LIBS) {
        LUA_LIBS = $$system(pkg-config --silence-errors --libs lua)
}

isEmpty (LUA_LIBS) {
        LUA_LIBS = $$system(pkg-config --silence-errors --libs lua5.1)
}

isEmpty (LUA_LIBS) {
	LUA_LIBS = $$system(pkg-config --silence-errors --libs lua-5.1)
}

isEmpty (PASM_CXXFLAGS) {
        PASM_CXXFLAGS = -Icompiler
}

isEmpty (PASM_LIBS) {
	PASM_LIBS = -Lcompiler -lpasm
}

# set platform specific cxxflags and libs
#########################################

win32 {
	SDL_CXXFLAGS = -I../nesicide/libraries/SDL 
	SDL_LIBS =  -L../nesicide/libraries/SDL/ -lsdl

	LUA_CXXFLAGS = -I../nesicide/libraries/Lua
	LUA_LIBS = ../nesicide/libraries/Lua/liblua.a

	PASM_LIBS = ../nesicide/compiler/libpasm.a

	NESICIDE_CXXFLAGS = -I../nesicide-emulator-lib -I../nesicide-emulator-lib/emulator

	QMAKE_LFLAGS += -static-libgcc

	release:LIBS += -L../nesicide-emulator-lib-build-desktop/release
	debug:LIBS += -L../nesicide-emulator-lib-build-desktop/debug
}

mac {
	NESICIDE_CXXFLAGS = -I ../nesicide-emulator-lib -I ../nesicide-emulator-lib/emulator
	NESICIDE_LIBS = -L../nesicide-emulator-lib-build-desktop -lnesicide-emulator

	SDL_CXXFLAGS = -framework SDL
	SDL_LIBS = -framework SDL

	LUA_CXXFLAGS = -F.. -framework Lua
	LUA_LIBS = -F.. -framework Lua

	TARGET = "NESICIDE"

	QMAKE_POST_LINK += mkdir -p $$TARGET.app/Contents/Frameworks $$escape_expand(\n\t)
	QMAKE_POST_LINK += cp ../nesicide-emulator-lib-build-desktop/libnesicide-emulator.1.0.0.dylib \
		$$TARGET.app/Contents/Frameworks/libnesicide-emulator.1.dylib $$escape_expand(\n\t)
	QMAKE_POST_LINK += install_name_tool -change libnesicide-emulator.1.dylib \
		@executable_path/../Frameworks/libnesicide-emulator.1.dylib \
		$$TARGET.app/Contents/MacOS/NESICIDE $$escape_expand(\n\t)
	QMAKE_POST_LINK += cp -r ../Lua.framework \
		$$TARGET.app/Contents/Frameworks/ $$escape_expand(\n\t)
}

unix:!mac {
	PREFIX = $$(PREFIX)
	isEmpty (PREFIX) {
		PREFIX = /usr/local
	}

	BINDIR = $$(BINDIR)
	isEmpty (BINDIR) {
                BINDIR=$$PREFIX/bin
	}

	target.path = $$BINDIR
	INSTALLS += target
}

QMAKE_CXXFLAGS += $$NESICIDE_CXXFLAGS $$SDL_CXXFLAGS $$LUA_CXXFLAGS $$PASM_CXXFLAGS
LIBS += $$NESICIDE_LIBS $$SDL_LIBS $$LUA_LIBS $$PASM_LIBS

INCLUDEPATH += common \
    debugger \
    designers/cartridge_editor \
    designers/code_editor \
    designers/new_project \
    designers/project_properties \
    designers/graphics_bank_editor \
    emulator \
    interfaces \
    project \
    plugins \
    resources \
    viewers \
    viewers/chr-rom \
    viewers/debugger \
    viewers/emulator \
    viewers/prg-rom \
    viewers/project_treeview

SOURCES += mainwindow.cpp \
    main.cpp \
    common/qtcolorpicker.cpp \
    common/cnessystempalette.cpp \
    common/cgltexturemanager.cpp \
    compiler/csourceassembler.cpp \
    compiler/cgraphicsassembler.cpp \
    compiler/ccartridgebuilder.cpp \
    designers/code_editor/csyntaxhighlighter.cpp \
    designers/code_editor/csyntaxhighlightedtextedit.cpp \
    designers/code_editor/codeeditorform.cpp \
    designers/new_project/newprojectdialog.cpp \
    designers/project_properties/projectpropertiesdialog.cpp \
    project/csources.cpp \
    project/csourceitem.cpp \
    project/cprojectprimitives.cpp \
    project/cproject.cpp \
    project/cprgrombanks.cpp \
    project/cprgrombank.cpp \
    project/cnesicideproject.cpp \
    project/cchrrombanks.cpp \
    project/cchrrombank.cpp \
    project/ccartridge.cpp \
    project/cbinaryfiles.cpp \
    viewers/chr-rom/chrromdisplaydialog.cpp \
    viewers/chr-rom/cchrrompreviewrenderer.cpp \
    viewers/emulator/nesemulatorrenderer.cpp \
    viewers/emulator/nesemulatordialog.cpp \
    viewers/prg-rom/prgromdisplaydialog.cpp \
    viewers/project_treeview/cprojecttreeviewmodel.cpp \
    viewers/project_treeview/cprojecttreeview.cpp \
    common/cbuildertextlogger.cpp \
    debugger/chrmeminspector.cpp \
    debugger/oaminspector.cpp \
    debugger/oamdisplaydialog.cpp \
    debugger/coampreviewrenderer.cpp \
    debugger/nametabledisplaydialog.cpp \
    debugger/cnametablepreviewrenderer.cpp \
    debugger/nametableinspector.cpp \
    debugger/executiontracerdialog.cpp \
    project/cbinaryfile.cpp \
    project/cgraphics.cpp \
    project/cgraphicsbanks.cpp \
    project/cgraphicsbank.cpp \
    designers/graphics_bank_editor/graphicsbankeditorform.cpp \
    viewers/debugger/cdebuggerexecutiontracermodel.cpp \
    debugger/executioninspector.cpp \
    debugger/memorydisplaydialog.cpp \
    debugger/memoryinspector.cpp \
    viewers/debugger/cdebuggermemorydisplaymodel.cpp \
    debugger/registerdisplaydialog.cpp \
    viewers/debugger/cdebuggerregisterdisplaymodel.cpp \
    debugger/registerinspector.cpp \
    viewers/debugger/cdebuggerregistercomboboxdelegate.cpp \
    debugger/breakpointdialog.cpp \
    debugger/breakpointinspector.cpp \
    viewers/debugger/cbreakpointdisplaymodel.cpp \
    debugger/breakpointwatcherthread.cpp \
    emulator/nesemulatorthread.cpp \
    debugger/codebrowserdialog.cpp \
    debugger/codeinspector.cpp \
    viewers/debugger/ccodebrowserdisplaymodel.cpp \
    common/inspectorregistry.cpp \
    viewers/debugger/csourcebrowserdisplaymodel.cpp \
    aboutdialog.cpp \
    designers/graphics_bank_editor/graphicsbankadditemsdialog.cpp \
    viewers/chr-rom/cchrromitemlistdisplaymodel.cpp \
    debugger/ppuinformationdialog.cpp \
    debugger/ppuinformationinspector.cpp \
    debugger/codedataloggerdialog.cpp \
    debugger/codedataloggerinspector.cpp \
    debugger/ccodedataloggerrenderer.cpp \
    project/cattributetables.cpp \
    debugger/executionvisualizer.cpp \
    debugger/executionvisualizerdialog.cpp \
    debugger/cexecutionvisualizerrenderer.cpp \
    debugger/mapperinformationdialog.cpp \
    debugger/mapperinformationinspector.cpp \
    debugger/apuinformationdialog.cpp \
    debugger/apuinformationinspector.cpp \
    common/cgamedatabasehandler.cpp \
    common/cconfigurator.cpp \
    environmentsettingsdialog.cpp \
    plugins/cpluginmanager.cpp \
    startupsplashdialog.cpp \
    debugger/dbg_cnes6502.cpp \
    debugger/dbg_cnesmappers.cpp \
    debugger/dbg_cnesppu.cpp \
    debugger/dbg_cnes.cpp \
    debugger/dbg_cnesapu.cpp \
    debugger/dbg_cnesrom.cpp \
    debugger/dbg_cnesrommapper004.cpp \
    debugger/dbg_cnesrommapper001.cpp \
    outputdockwidget.cpp \
    outputdialog.cpp \
    compiler/compilerthread.cpp \
    emulatorprefsdialog.cpp \
    qkeymapitemedit.cpp

HEADERS += mainwindow.h \
    main.h \
    common/qtcolorpicker.h \
    common/defaultnespalette.h \
    common/cpaletteitemdelegate.h \
    common/cnessystempalette.h \
    common/cgltexturemanager.h \
    compiler/csourceassembler.h \
    compiler/cgraphicsassembler.h \
    compiler/ccartridgebuilder.h \
    designers/code_editor/csyntaxhighlighter.h \
    designers/code_editor/csyntaxhighlightedtextedit.h \
    designers/code_editor/codeeditorform.h \
    designers/new_project/newprojectdialog.h \
    designers/project_properties/projectpropertiesdialog.h \
    interfaces/ixmlserializable.h \
    interfaces/iprojecttreeviewitem.h \
    project/csources.h \
    project/csourceitem.h \
    project/cprojectprimitives.h \
    project/cproject.h \
    project/cprgrombanks.h \
    project/cprgrombank.h \
    project/cnesicideproject.h \
    project/cchrrombanks.h \
    project/cchrrombank.h \
    project/ccartridge.h \
    project/cbinaryfiles.h \
    viewers/chr-rom/chrromdisplaydialog.h \
    viewers/chr-rom/cchrrompreviewrenderer.h \
    viewers/emulator/nesemulatorrenderer.h \
    viewers/emulator/nesemulatordialog.h \
    viewers/prg-rom/prgromdisplaydialog.h \
    viewers/project_treeview/cprojecttreeviewmodel.h \
    viewers/project_treeview/cprojecttreeview.h \
    common/cbuildertextlogger.h \
    debugger/chrmeminspector.h \
    debugger/oaminspector.h \
    debugger/oamdisplaydialog.h \
    debugger/coampreviewrenderer.h \
    debugger/nametabledisplaydialog.h \
    debugger/cnametablepreviewrenderer.h \
    debugger/nametableinspector.h \
    debugger/executiontracerdialog.h \
    emulator/nesemulatorthread.h \
    project/cbinaryfile.h \
    project/cgraphics.h \
    project/cgraphicsbanks.h \
    project/cgraphicsbank.h \
    designers/graphics_bank_editor/graphicsbankeditorform.h \
    viewers/debugger/cdebuggerexecutiontracermodel.h \
    debugger/executioninspector.h \
    debugger/memorydisplaydialog.h \
    debugger/memoryinspector.h \
    viewers/debugger/cdebuggermemorydisplaymodel.h \
    debugger/registerdisplaydialog.h \
    viewers/debugger/cdebuggerregisterdisplaymodel.h \
    debugger/registerinspector.h \
    viewers/debugger/cdebuggerregistercomboboxdelegate.h \
    debugger/breakpointdialog.h \
    debugger/breakpointinspector.h \
    viewers/debugger/cbreakpointdisplaymodel.h \
    debugger/breakpointwatcherthread.h \
    debugger/codebrowserdialog.h \
    debugger/codeinspector.h \
    viewers/debugger/ccodebrowserdisplaymodel.h \
    common/inspectorregistry.h \
    compiler/pasm_types.h \
    compiler/pasm_lib.h \
    viewers/debugger/csourcebrowserdisplaymodel.h \
    aboutdialog.h \
    interfaces/ichrrombankitem.h \
    designers/graphics_bank_editor/graphicsbankadditemsdialog.h \
    viewers/chr-rom/cchrromitemlistdisplaymodel.h \
    debugger/ppuinformationdialog.h \
    debugger/ppuinformationinspector.h \
    debugger/codedataloggerdialog.h \
    debugger/codedataloggerinspector.h \
    debugger/ccodedataloggerrenderer.h \
    project/cattributetables.h \
    debugger/executionvisualizer.h \
    debugger/executionvisualizerdialog.h \
    debugger/cexecutionvisualizerrenderer.h \
    debugger/mapperinformationdialog.h \
    debugger/mapperinformationinspector.h \
    debugger/apuinformationdialog.h \
    debugger/apuinformationinspector.h \
    common/cgamedatabasehandler.h \
    common/cconfigurator.h \
    environmentsettingsdialog.h \
    plugins/cpluginmanager.h \
    startupsplashdialog.h \
    common/cnessystempalette.h \
    debugger/dbg_cnes6502.h \
    debugger/dbg_cnesmappers.h \
    debugger/dbg_cnesppu.h \
    debugger/dbg_cnes.h \
    debugger/dbg_cnesrom.h \
    debugger/dbg_cnesapu.h \
    debugger/dbg_cnesrommapper001.h \
    debugger/dbg_cnesrommapper004.h \
    outputdockwidget.h \
    outputdialog.h \
    compiler/compilerthread.h \
    emulatorprefsdialog.h \
    qkeymapitemedit.h

FORMS += mainwindow.ui \
    designers/code_editor/codeeditorform.ui \
    designers/new_project/newprojectdialog.ui \
    designers/project_properties/projectpropertiesdialog.ui \
    viewers/chr-rom/chrromdisplaydialog.ui \
    viewers/emulator/nesemulatordialog.ui \
    viewers/prg-rom/prgromdisplaydialog.ui \
    debugger/oamdisplaydialog.ui \
    debugger/nametabledisplaydialog.ui \
    debugger/executiontracerdialog.ui \
    designers/graphics_bank_editor/graphicsbankeditorform.ui \
    debugger/memorydisplaydialog.ui \
    debugger/registerdisplaydialog.ui \
    debugger/breakpointdialog.ui \
    debugger/codebrowserdialog.ui \
    aboutdialog.ui \
    designers/graphics_bank_editor/graphicsbankadditemsdialog.ui \
    debugger/ppuinformationdialog.ui \
    debugger/codedataloggerdialog.ui \
    debugger/executionvisualizerdialog.ui \
    debugger/mapperinformationdialog.ui \
    debugger/apuinformationdialog.ui \
    environmentsettingsdialog.ui \
    startupsplashdialog.ui \
    outputdialog.ui \
    emulatorprefsdialog.ui

RESOURCES += resource.qrc
