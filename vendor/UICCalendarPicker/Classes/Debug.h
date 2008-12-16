#ifdef DEBUG
#  define LOG(...) NSLog(__VA_ARGS__)
#  define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#else
#  define LOG(...) ;
#  define LOG_CURRENT_METHOD ;
#endif
