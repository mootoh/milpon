#ifdef DEBUG

#define LOG(...) NSLog(__VA_ARGS__)
#define LOG_CURRENT_METHOD NSLog(NSStringFromSelector(_cmd))

#else // DEBUG

#define LOG(...) ;
#define LOG_CURRENT_METHOD ;

#endif // DEBUG
