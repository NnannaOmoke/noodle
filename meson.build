project('noodle', 'c')
myinc = include_directories('src/include','src/utils')
libpath = 'src/utils/'
utils = library('utils', sources: [libpath / 'utils.h', libpath / 'utils.c'])

executable('noodle',
            'src/main.c',
            include_directories: myinc,
            link_with: utils)
