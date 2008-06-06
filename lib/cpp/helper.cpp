#include "../helper.h"

irrklang::ISoundEngine *create_default_device(Rice::Object self) {
  return irrklang::createIrrKlangDevice();
}