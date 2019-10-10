module accelerator #(
  parameter int unsigned ID_WIDTH  = 0
) (
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          test_mode_i,

  XBAR_TCDM_BUS.Master  tcdm_bus,
  XBAR_PERIPH_BUS.Slave cfg_bus
);
  // Constants
  localparam int unsigned MEM_SPACE  = 8;
  localparam int unsigned ADDR_WIDTH = 32;
  localparam int unsigned DATA_WIDTH = 32;

  // --------------------------------------------
  // Configuration
  // --------------------------------------------
  // Address Map
  localparam logic[MEM_SPACE-1:0] OPERAND_A_ADDR = 8'h00;
  localparam logic[MEM_SPACE-1:0] OPERAND_B_ADDR = 8'h04;
  localparam logic[MEM_SPACE-1:0] RESULT_ADDR    = 8'h08;
  localparam logic[MEM_SPACE-1:0] START          = 8'h0C;
  localparam logic[MEM_SPACE-1:0] STATUS         = 8'h10;
  // Configuration registers
  logic [ADDR_WIDTH-1:0] operand_a_addr_q, operand_a_addr_d;
  logic [ADDR_WIDTH-1:0] operand_b_addr_q, operand_b_addr_d;
  logic [ADDR_WIDTH-1:0] result_addr_q, result_addr_d;
  logic                  start_q, start_d;
  logic                  status_q, status_d;
  // Read request register
  logic [DATA_WIDTH-1:0] r_data_q, r_data_d;
  logic [ID_WIDTH-1:0]   r_id_q, r_id_d;
  logic                  r_valid_q, r_valid_d;

  always_comb begin : proc_register
    // Default mappings
    operand_a_addr_d = operand_a_addr_q;
    operand_b_addr_d = operand_b_addr_q;
    result_addr_d    = result_addr_q;
    start_d          = start_q;
    status_d         = status_q;
    // Read repsonse
    r_data_d         = r_data_q;
    r_id_d           = cfg_bus.id;
    cfg_bus.gnt      = 1'b0;

    // Read
    if (cfg_bus.req && cfg_bus.wen) begin
      cfg_bus.gnt = 1'b1;
      case (cfg_bus.add[MEM_SPACE-1:0])
        OPERAND_A_ADDR: begin
          r_data_d = operand_a_addr_q;
        end
        OPERAND_B_ADDR: begin
          r_data_d = operand_b_addr_q;
        end
        RESULT_ADDR: begin
          r_data_d = result_addr_q;
        end
        START: begin
          r_data_d    = '0;
          r_data_d[0] = start_q;
        end
        STATUS: begin
          r_data_d    = '0;
          r_data_d[0] = status_q;
        end
        default : r_data_d = '1;
      endcase
    end
    // Write
    else if (cfg_bus.req && !cfg_bus.wen) begin
      cfg_bus.gnt = 1'b1;
      case (cfg_bus.add[MEM_SPACE-1:0])
        OPERAND_A_ADDR: begin
          operand_a_addr_d = cfg_bus.wdata;
        end
        OPERAND_B_ADDR: begin
          operand_b_addr_d = cfg_bus.wdata;
        end
        RESULT_ADDR: begin
          result_addr_d = cfg_bus.wdata;
        end
        START: begin
          start_q = cfg_bus.wdata[0];
        end
        STATUS: begin
          status_q = cfg_bus.wdata[0];
        end
      endcase
    end
  end

  // Always answer both read and write requests with read valid
  assign r_valid_d = cfg_bus.req;

  // Configuration response
  assign cfg_bus.r_rdata = r_data_q;
  assign cfg_bus.r_opc   = 1'b0;
  assign cfg_bus.r_id    = r_id_q;
  assign cfg_bus.r_valid = r_valid_q;

  // FF process
  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_registers_ff
    if(~rst_ni) begin
      operand_a_addr_q <= '0;
      operand_b_addr_q <= '0;
      result_addr_q    <= '0;
      start_q          <= '0;
      status_q         <= '0;
      r_data_q         <= '0;
      r_valid_q        <= '0;
      r_id_q           <= '0;
    end else begin
      operand_a_addr_q <= operand_a_addr_d;
      operand_b_addr_q <= operand_b_addr_d;
      result_addr_q    <= result_addr_d;
      start_q          <= start_d;
      status_q         <= status_d;
      r_data_q         <= r_data_d;
      r_valid_q        <= r_valid_d;
      r_id_q           <= r_id_d;
    end
  end : proc_registers_ff

  // --------------------------------------------
  // Memory Interface
  // --------------------------------------------
  assign tcdm_bus.req     = '0;
  assign tcdm_bus.add     = '0;
  assign tcdm_bus.wen     = '0;
  assign tcdm_bus.wdata   = '0;
  assign tcdm_bus.be      = '0;



endmodule
