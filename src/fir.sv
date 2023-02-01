module fir
	//--------------------- PARAMETERS ---------------------------------
  #(
    parameter SAMPLE_WIDTH    = 16
   ,parameter COEFF_WIDTH     = 16
   ,parameter N_TAPS          = 41
  )
	//----------------------- PORTS ------------------------------------
  (
    input                                   clk
   ,input                                   rst_n
   ,input                                   clr
   ,input  signed [COEFF_WIDTH  -1 : 0]     coeff_in     [N_TAPS : 0]
   ,input                                   coeff_valid
   ,input  signed [SAMPLE_WIDTH -1 : 0]     fir_in
   ,output signed [SAMPLE_WIDTH + COEFF_WIDTH + N_TAPS -1 : 0] fir_out 
  );

  //------------------------------------------------------------
  // Coefficient Register
  //------------------------------------------------------------
  logic signed [SAMPLE_WIDTH -1 : 0] coeff_reg [N_TAPS : 0];
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) 
      for (int i=0; i<N_TAPS+1; i++)
        coeff_reg[i]   <= {COEFF_WIDTH{1'b0}};
    else if (clr)
      for (integer i=0; i<N_TAPS+1; i++)
        coeff_reg[i]   <= {COEFF_WIDTH{1'b0}};
    else if (coeff_valid) 
        coeff_reg      <= coeff_in;

  //------------------------------------------------------------
  // Chain of Delay Buffers
  //------------------------------------------------------------
  logic signed [SAMPLE_WIDTH -1 : 0] delay_buff [N_TAPS -1 : 0];

  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) 
      for (integer i=0; i<N_TAPS; i++)
        delay_buff[i]   <= {SAMPLE_WIDTH{1'b0}};
    else if (clr)
      for (integer i=0; i<N_TAPS; i++)
        delay_buff[i]   <= {SAMPLE_WIDTH{1'b0}};
    else
    begin
        delay_buff[0]   <= fir_in;
        for (integer i=1; i<N_TAPS; i++)
          delay_buff[i]   <= delay_buff[i-1];
    end

  //------------------------------------------------------------
  // Multipliers Logic
  //------------------------------------------------------------
  logic signed [SAMPLE_WIDTH + COEFF_WIDTH -1 : 0] product [N_TAPS : 0];

  always_comb
  begin
    product[0] = fir_in * coeff_in[0];
    for (integer i=1; i<N_TAPS+1; i++)
      product[i] = delay_buff[i-1] * coeff_in[i];
  end

  //------------------------------------------------------------
  // Accumulation Logic
  //------------------------------------------------------------
  logic signed [SAMPLE_WIDTH + COEFF_WIDTH + N_TAPS -1 : 0] accumlate [N_TAPS -1 : 0];

  always_comb
  begin
    accumlate[0] = product[0] + product[1];
    for (integer i=1; i<N_TAPS; i++)
      accumlate[i] = accumlate[i-1] + product[i+1];
  end

  //------------------------------------------------------------
  // Drive the Output of the Filter
  //------------------------------------------------------------
  assign fir_out = accumlate[N_TAPS-1];
  
endmodule
