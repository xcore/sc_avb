#include <xs1.h>
#include <platform.h>

#include "tsi_output.h"
#include "avb_conf.h"

#if AVB_NUM_MEDIA_OUTPUTS > 0

#pragma xta command "remove exclusion *"
#pragma xta command "analyze endpoints ts_spi_output_first ts_spi_output_loop"
#pragma xta command "set required - 148 ns"

#pragma xta command "remove exclusion *"
#pragma xta command "add exclusion ts_spi_output_loop"
#pragma xta command "add exclusion ts_spi_output_no_data"
#pragma xta command "analyze endpoints ts_spi_output_loop ts_spi_output_first"
#pragma xta command "set required - 148 ns"

#pragma unsafe arrays
void tsi_output(clock clk, out buffered port:32 p_data, in port p_clk, out
buffered port:4 p_sync, out port p_valid,
        media_output_fifo_data_t& ofifo)
{
  // Intialise port, clearbufs and start clock last
  configure_clock_src(clk, p_clk);
  configure_out_port_strobed_master(p_data, p_valid, clk, 0);

  clearbuf(p_data);
  clearbuf(p_sync);

  start_clock(clk);

  unsafe {
    unsigned *unsafe start_ptr = &ofifo.fifo[0];
    unsigned *unsafe end_ptr = &ofifo.fifo[MEDIA_OUTPUT_FIFO_WORD_SIZE-1];
    unsigned *unsafe rd_ptr = start_ptr;
    volatile unsigned * unsafe test_ptr = rd_ptr + MEDIA_OUTPUT_FIFO_INUSE_OFFSET;

    while (1) {
#pragma xta label "ts_spi_output_no_data"
      // Wait for the next packet
      while (*test_ptr) {
        // Wait until it is time to transmit the packet
        unsigned ts = *rd_ptr++;
        // Transmit first word
        sync(p_data);
#pragma xta endpoint "ts_spi_output_first"
        p_sync <: 1;
        p_data <: *rd_ptr++;

#pragma loop unroll
        for (unsigned i=0; i<46; i++) {
#pragma xta endpoint "ts_spi_output_loop"
          p_sync <: 0;
          p_data <: *rd_ptr++;
        }

        *rd_ptr++ = 0;
        if (rd_ptr > end_ptr)
          rd_ptr = start_ptr;

        test_ptr = rd_ptr + MEDIA_OUTPUT_FIFO_INUSE_OFFSET;
      }
    }
  }
}

#endif

