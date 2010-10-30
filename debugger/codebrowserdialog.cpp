#include "codebrowserdialog.h"
#include "ui_codebrowserdialog.h"

#include "dbg_cnes.h"
#include "dbg_cnes6502.h"
#include "dbg_cnesrom.h"
#include "pasm_lib.h"

#include "inspectorregistry.h"
#include "main.h"

#include "cmarker.h"

#include <QMessageBox>

#define BROWSE_ASSEMBLY 0
#define BROWSE_SOURCE   1

CodeBrowserDialog::CodeBrowserDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::CodeBrowserDialog)
{
    QDockWidget* breakpointInspector = InspectorRegistry::getInspector("Breakpoints");

    ui->setupUi(this);
    assemblyViewModel = new CCodeBrowserDisplayModel(this);
    sourceViewModel = new CSourceBrowserDisplayModel(this);
    ui->tableView->setModel(assemblyViewModel);
    ui->displayMode->setCurrentIndex ( 0 );
    QObject::connect ( emulator, SIGNAL(cartridgeLoaded()), this, SLOT(updateBrowser()) );
    QObject::connect ( emulator, SIGNAL(emulatedFrame()), this, SLOT(updateBrowser()) );
    QObject::connect ( emulator, SIGNAL(emulatorPaused(bool)), this, SLOT(updateDisassembly(bool)) );
    QObject::connect ( emulator, SIGNAL(emulatorReset()), this, SLOT(updateBrowser()) );
    QObject::connect ( breakpointWatcher, SIGNAL(breakpointHit()), this, SLOT(breakpointHit()) );
    QObject::connect ( breakpointInspector->widget(), SIGNAL(breakpointsChanged()), this, SLOT(updateBrowser()) );
    QObject::connect ( this, SIGNAL(breakpointsChanged()), breakpointInspector->widget(), SLOT(updateData()) );
}

CodeBrowserDialog::~CodeBrowserDialog()
{
    delete ui;
    delete assemblyViewModel;
    delete sourceViewModel;
}

void CodeBrowserDialog::showEvent(QShowEvent* e)
{
   QDialog::showEvent(e);

   // Update display...
   nesDisassemble();

   switch ( ui->displayMode->currentIndex() )
   {
      case BROWSE_ASSEMBLY:
         assemblyViewModel->layoutChangedEvent();
         ui->tableView->setCurrentIndex(assemblyViewModel->index(nesGetSLOCFromAddress(C6502DBG::__PC()),0));
      break;
      case BROWSE_SOURCE:
         sourceViewModel->layoutChangedEvent();
         ui->tableView->setCurrentIndex(sourceViewModel->index(pasm_get_source_linenum(nesGetAbsoluteAddressFromAddress(C6502DBG::__PC()))-1,0));
      break;
   }

   ui->tableView->resizeColumnsToContents();
}

void CodeBrowserDialog::contextMenuEvent(QContextMenuEvent *e)
{
   CBreakpointInfo* pBreakpoints = nesGetBreakpointDatabase();
   QMenu menu;
   int bp;
   int addr = 0;
   QModelIndex index = ui->tableView->currentIndex();

   switch ( ui->displayMode->currentIndex() )
   {
      case BROWSE_ASSEMBLY:
         addr = nesGetAddressFromSLOC(index.row());
      break;
      case BROWSE_SOURCE:
         addr = pasm_get_source_addr_from_linenum ( index.row()+1 );
      break;
   }

   bp = pBreakpoints->FindExactMatch ( eBreakOnCPUExecution,
                                       eBreakpointItemAddress,
                                       0,
                                       addr,
                                       addr,
                                       eBreakpointConditionNone,
                                       0,
                                       eBreakpointDataNone,
                                       0 );

   // Build context menu...
   menu.addAction(ui->actionRun_to_here);
   menu.addSeparator();

   // If breakpoint isn't set here, give menu options to set one...
   if ( bp < 0 )
   {
      menu.addAction(ui->actionBreak_on_CPU_execution_here);
   }
   else
   {
      if ( pBreakpoints->GetStatus(bp) == Breakpoint_Disabled )
      {
         menu.addAction(ui->actionEnable_breakpoint);
         menu.addAction(ui->actionRemove_breakpoint);
      }
      else
      {
         menu.addAction(ui->actionDisable_breakpoint);
         menu.addAction(ui->actionRemove_breakpoint);
      }
   }

   menu.addSeparator();
   menu.addAction(ui->actionClear_marker);
   menu.addSeparator();

   menu.addAction(ui->actionStart_marker_here);
   menu.addAction(ui->actionEnd_marker_here);

   // Run the context menu...
   // CPTODO: Hokey trick to provide the breakpoint-of-interest to action handlers...
   m_breakpointIndex = bp;

   menu.exec(e->globalPos());

   emit breakpointsChanged();
}

void CodeBrowserDialog::changeEvent(QEvent *e)
{
    QDialog::changeEvent(e);
    switch (e->type()) {
    case QEvent::LanguageChange:
        ui->retranslateUi(this);
        break;
    default:
        break;
    }
}

void CodeBrowserDialog::breakpointHit()
{
   updateDisassembly(true);
}

void CodeBrowserDialog::updateDisassembly(bool show)
{
   // Update display...
   nesDisassemble();

   if ( show )
   {
      emit showMe();
   }

   if ( isVisible() )
   {
      switch ( ui->displayMode->currentIndex() )
      {
         case BROWSE_ASSEMBLY:
            assemblyViewModel->layoutChangedEvent();
            ui->tableView->setCurrentIndex(assemblyViewModel->index(nesGetSLOCFromAddress(C6502DBG::__PC()),0));
         break;
         case BROWSE_SOURCE:
            sourceViewModel->layoutChangedEvent();
            ui->tableView->setCurrentIndex(sourceViewModel->index(pasm_get_source_linenum(nesGetAbsoluteAddressFromAddress(C6502DBG::__PC()))-1,0));
         break;
      }
   }
}

void CodeBrowserDialog::updateBrowser()
{
   CBreakpointInfo* pBreakpoints = nesGetBreakpointDatabase();
   int idx;

   // Check breakpoints for hits and highlight if necessary...
   for ( idx = 0; idx < pBreakpoints->GetNumBreakpoints(); idx++ )
   {
      BreakpointInfo* pBreakpoint = pBreakpoints->GetBreakpoint(idx);
      if ( pBreakpoint->hit )
      {
         // Update display...
         nesDisassemble();

         emit showMe();
         break;
      }
   }

   if ( isVisible() )
   {
      switch ( ui->displayMode->currentIndex() )
      {
         case BROWSE_ASSEMBLY:
            assemblyViewModel->layoutChangedEvent();
            ui->tableView->setCurrentIndex(assemblyViewModel->index(nesGetSLOCFromAddress(C6502DBG::__PC()),0));
         break;
         case BROWSE_SOURCE:
            sourceViewModel->layoutChangedEvent();
            ui->tableView->setCurrentIndex(sourceViewModel->index(pasm_get_source_linenum(nesGetAbsoluteAddressFromAddress(C6502DBG::__PC()))-1,0));
         break;
      }
   }
}

void CodeBrowserDialog::on_actionBreak_on_CPU_execution_here_triggered()
{
   CBreakpointInfo* pBreakpoints = nesGetBreakpointDatabase();
   QModelIndex index = ui->tableView->currentIndex();
   bool added;
   int addr = 0;

   switch ( ui->displayMode->currentIndex() )
   {
      case BROWSE_ASSEMBLY:
         addr = nesGetAddressFromSLOC(index.row());
      break;
      case BROWSE_SOURCE:
         addr = pasm_get_source_addr_from_linenum ( index.row()+1 );
      break;
   }

   added = pBreakpoints->AddBreakpoint ( eBreakOnCPUExecution,
                                         eBreakpointItemAddress,
                                         0,
                                         addr,
                                         addr,
                                         eBreakpointConditionNone,
                                         0,
                                         eBreakpointDataNone,
                                         0 );

   if ( !added )
   {
      QMessageBox::information(0, "Error", "Cannot add breakpoint, already have 8 defined.");
   }

   InspectorRegistry::getInspector("Breakpoints")->hide();
   InspectorRegistry::getInspector("Breakpoints")->show();

   emit breakpointsChanged();
}

void CodeBrowserDialog::on_actionRun_to_here_triggered()
{
   QModelIndex index = ui->tableView->currentIndex();
   int addr = 0;

   switch ( ui->displayMode->currentIndex() )
   {
      case BROWSE_ASSEMBLY:
         addr = nesGetAddressFromSLOC(index.row());
      break;
      case BROWSE_SOURCE:
         addr = pasm_get_source_addr_from_linenum ( index.row()+1 );
      break;
   }

   C6502DBG::GOTO(addr);
}

void CodeBrowserDialog::on_displayMode_currentIndexChanged(int index)
{
   switch ( index )
   {
      case BROWSE_ASSEMBLY:
         ui->tableView->setModel(assemblyViewModel);
         assemblyViewModel->layoutChangedEvent();
      break;
      case BROWSE_SOURCE:
         ui->tableView->setModel(sourceViewModel);
         sourceViewModel->layoutChangedEvent();
      break;
   }

   updateDisassembly(false);

   ui->tableView->resizeColumnsToContents();
}

void CodeBrowserDialog::on_tableView_doubleClicked(QModelIndex index)
{
   CBreakpointInfo* pBreakpoints = nesGetBreakpointDatabase();
   int bp;
   int addr = 0;

   if ( index.isValid() )
   {
      switch ( ui->displayMode->currentIndex() )
      {
         case BROWSE_ASSEMBLY:
            addr = nesGetAddressFromSLOC(index.row());
         break;
         case BROWSE_SOURCE:
            addr = pasm_get_source_addr_from_linenum ( index.row()+1 );
         break;
      }

      bp = pBreakpoints->FindExactMatch ( eBreakOnCPUExecution,
                                          eBreakpointItemAddress,
                                          0,
                                          addr,
                                          addr,
                                          eBreakpointConditionNone,
                                          0,
                                          eBreakpointDataNone,
                                          0 );

      if ( bp < 0 )
      {
         on_actionBreak_on_CPU_execution_here_triggered();
      }
      else
      {
         pBreakpoints->RemoveBreakpoint(bp);
      }

      switch ( ui->displayMode->currentIndex() )
      {
         case BROWSE_ASSEMBLY:
            assemblyViewModel->layoutChangedEvent();
         break;
         case BROWSE_SOURCE:
            sourceViewModel->layoutChangedEvent();
         break;
      }
      emit breakpointsChanged();
   }
}

void CodeBrowserDialog::on_actionDisable_breakpoint_triggered()
{
   CBreakpointInfo* pBreakpoints = nesGetBreakpointDatabase();
   if ( m_breakpointIndex >= 0 )
   {
      pBreakpoints->ToggleEnabled(m_breakpointIndex);
   }
}

void CodeBrowserDialog::on_actionRemove_breakpoint_triggered()
{
   CBreakpointInfo* pBreakpoints = nesGetBreakpointDatabase();
   if ( m_breakpointIndex >= 0 )
   {
      pBreakpoints->RemoveBreakpoint(m_breakpointIndex);
   }
}

void CodeBrowserDialog::on_actionEnable_breakpoint_triggered()
{
   CBreakpointInfo* pBreakpoints = nesGetBreakpointDatabase();
   if ( m_breakpointIndex >= 0 )
   {
      pBreakpoints->ToggleEnabled(m_breakpointIndex);
   }
}

void CodeBrowserDialog::on_actionStart_marker_here_triggered()
{
   CMarker* markers = nesGetExecutionMarkerDatabase();
   int marker;
   int addr = 0;
   QModelIndex index = ui->tableView->currentIndex();

   if ( index.isValid() )
   {
      switch ( ui->displayMode->currentIndex() )
      {
         case BROWSE_ASSEMBLY:
            addr = nesGetAddressFromSLOC(index.row());
         break;
         case BROWSE_SOURCE:
            addr = pasm_get_source_addr_from_linenum ( index.row()+1 );
         break;
      }

      // Find unused Marker entry...
      marker = markers->AddMarker(nesGetAbsoluteAddressFromAddress(addr));
   }
}

void CodeBrowserDialog::on_actionEnd_marker_here_triggered()
{
   CMarker* markers = nesGetExecutionMarkerDatabase();
   int marker = markers->FindInProgressMarker();
   int addr = 0;
   QModelIndex index = ui->tableView->currentIndex();

   if ( marker >= 0 )
   {
      switch ( ui->displayMode->currentIndex() )
      {
         case BROWSE_ASSEMBLY:
            addr = nesGetAddressFromSLOC(index.row());
         break;
         case BROWSE_SOURCE:
            addr = pasm_get_source_addr_from_linenum ( index.row()+1 );
         break;
      }

      markers->CompleteMarker(marker,nesGetAbsoluteAddressFromAddress(addr));
   }
}

void CodeBrowserDialog::on_actionClear_marker_triggered()
{
   CMarker* markers = nesGetExecutionMarkerDatabase();
   markers->ClearAllMarkers();
}

