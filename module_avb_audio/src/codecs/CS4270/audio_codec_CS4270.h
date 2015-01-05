#ifndef _audio_codec_CS42448_h_
#define _audio_codec_CS42448_h_
#include "avb_conf.h"
#include "i2c.h"

#define CODEC_DEV_ID_ADDR           0x01
#define CODEC_PWR_CTRL_ADDR         0x02
#define CODEC_MODE_CTRL_ADDR        0x03
#define CODEC_ADC_DAC_CTRL_ADDR     0x04
#define CODEC_TRAN_CTRL_ADDR        0x05
#define CODEC_MUTE_CTRL_ADDR        0x06
#define CODEC_DACA_VOL_ADDR         0x07
#define CODEC_DACB_VOL_ADDR         0x08

void audio_codec_CS4270_init(out port p_codec_reset,
                              int mask,
                              int codec_addr,
                        #if I2C_COMBINE_SCL_SDA
                              port r_i2c
                        #else
                              struct r_i2c &r_i2c
                        #endif
                              );



#endif
