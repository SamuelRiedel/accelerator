module accelerator #(
  parameter int unsigned ID_WIDTH  = 0
) (
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          test_mode_i,

  XBAR_TCDM_BUS.Master  tcdm_bus,
  XBAR_PERIPH_BUS.Slave cfg_bus
);

  assign tcdm_bus.req     = '0;
  assign tcdm_bus.add     = '0;
  assign tcdm_bus.wen     = '0;
  assign tcdm_bus.wdata   = '0;
  assign tcdm_bus.be      = '0;

  assign cfg_bus.gnt     = '0;
  assign cfg_bus.r_rdata = '0;
  assign cfg_bus.r_opc   = '0;
  assign cfg_bus.r_id    = '0;
  assign cfg_bus.r_valid = '0;

  assign result = ~clk_i;

endmodule
