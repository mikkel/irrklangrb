#ifndef HELPER
#define HELPER

#include <vector>
#include <irrKlang.h>

#include "rice/Class.hpp"
#include "rice/Data_Type.hpp"
#include "rice/Constructor.hpp"
#include "rice/Enum.hpp"
#include "rice/to_from_ruby.hpp"
#include "rice/Address_Registration_Guard.hpp"

#include <ruby.h>

//template<>
//Rice::Object to_ruby<btMatrix3x3>(btMatrix3x3 const & x);

irrklang::ISoundEngine *create_default_device(Rice::Object self);

#endif