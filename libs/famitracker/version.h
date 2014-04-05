/*
** FamiTracker - NES/Famicom sound tracker
** Copyright (C) 2005-2012  Jonathan Liss
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful, 
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
** Library General Public License for more details.  To obtain a 
** copy of the GNU Library General Public License, write to the Free 
** Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
**
** Any permitted reproduction of these routines, in whole or in part,
** must bear this legend.
*/

#ifndef _VERSION_H_
#define _VERSION_H_

// Define this for beta builds
//#define WIP

// Version info
#define VERSION_MAJ  0
#define VERSION_MIN  4
#define VERSION_REV  2

// CP: Qt versioning adds a .x
#define VERSION_QT   8 // 2014-04-03

#define VERSION_WIP  0

#ifdef SVN_BUILD

#include "config.h"
#define VERSION VERSION_MAJ,VERSION_MIN,VERSION_REV,SVN_VERSION

#else

#define VERSION VERSION_MAJ,VERSION_MIN,VERSION_REV,VERSION_WIP

#endif /* SVN_BUILD */

#endif /* _VERSION_H_ */
