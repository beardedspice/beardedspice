//
//  BSLog.h
//  Beardie
//
//  Created by Roman Sokolov on 09.12.2019.
//  Copyright © 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#ifndef BSLog_h
#define BSLog_h

#pragma mark Logging Logic

#define BSLOG_DEBUG    1
#define BSLOG_INFO     2
#define BSLOG_ERROR    3
#define BSLOG_CRITICAL 4

#ifdef DEBUG
#define LOG_LEVEL BSLOG_DEBUG
#elif BETA
#define LOG_LEVEL BSLOG_INFO
#else // production
#define LOG_LEVEL BSLOG_ERROR
#endif

#define BSLog(x, frmt, ...) do { if (x >= LOG_LEVEL) { NSLog(@"(%s %s) " frmt, __FILE__, __FUNCTION__, ##__VA_ARGS__); } } while(0)

#endif /* BSLog_h */
