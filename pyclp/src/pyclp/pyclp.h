#ifndef __PYX_HAVE__pyclp__pyclp
#define __PYX_HAVE__pyclp__pyclp


#ifndef __PYX_HAVE_API__pyclp__pyclp

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

__PYX_EXTERN_C DL_IMPORT(int) call_python(void);

#endif /* !__PYX_HAVE_API__pyclp__pyclp */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initpyclp(void);
#else
PyMODINIT_FUNC PyInit_pyclp(void);
#endif

#endif /* !__PYX_HAVE__pyclp__pyclp */
