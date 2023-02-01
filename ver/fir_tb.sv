`timescale 1ns / 1ps
module fir_tb ();

  parameter CLK_T           = 10; // Fclk = 100 MHz
  parameter SAMPLE_WIDTH    = 16;
  parameter COEFF_WIDTH     = 16;
  parameter N_TAPS          = 41;

  logic                                clk;
  logic                                rst_n;
  logic                                clr;
  logic signed [COEFF_WIDTH  -1 : 0]   coeff_in     [N_TAPS : 0];
  logic                                coeff_valid;
  logic signed [SAMPLE_WIDTH -1 : 0]   fir_in;
  logic signed [SAMPLE_WIDTH + COEFF_WIDTH + N_TAPS -1 : 0] fir_out;

  //register declaration for files
  logic [SAMPLE_WIDTH -1:0] samples [2047:0];

  //------------------------------------------------------------
  // FIR Filter Instantaition
  //------------------------------------------------------------
  fir
  #(
    .SAMPLE_WIDTH  (SAMPLE_WIDTH)
   ,.COEFF_WIDTH   (COEFF_WIDTH )
   ,.N_TAPS        (N_TAPS      )
  )
    u_fir
  (
    .clk           (clk         )
   ,.rst_n         (rst_n       )
   ,.clr           (clr       )
   ,.coeff_in      (coeff_in    )
   ,.coeff_valid   (coeff_valid )
   ,.fir_in        (fir_in      )
   ,.fir_out       (fir_out     )
  );

  //------------------------------------------------------------
  // Generate Operating Clock
  //------------------------------------------------------------
  initial
  begin
    clk   = 1'b1;
    forever #(CLK_T / 2)
      clk = ~clk;
  end


  //------------------------------------------------------------
  // Apply test inputs to the FIR filter
  //------------------------------------------------------------
  initial
  begin
    iniate_sys;
    wr_lpf_coeff;
    insert_samples;
    wr_hpf_coeff;
    insert_samples;
    wr_bpf_coeff;
    insert_samples;
    $finish;
  end

  //------------------------------------------------------------
  // Task to initiate and reset the system
  //------------------------------------------------------------
  task iniate_sys;
    begin
    for (integer i=0; i<N_TAPS+1; i++)
    begin
      coeff_in[i] = '0;
    end
    fir_in        = 1'b0;
    rst_n         = 1'b1;
    clr           = 1'b0;
    coeff_valid   = '0;
    fir_in        = '0;
    rst_n         = 1'b0;
    @(posedge clk)
    @(negedge clk)
    rst_n      = 1'b1;
    @(negedge clk);
    end
  endtask

  //------------------------------------------------------------
  // Task to write LPF coefficient of FIR filter
  //------------------------------------------------------------
  task wr_lpf_coeff;
    begin
    @(posedge clk)
    @(negedge clk)
    clr           = 1'b1;
    @(posedge clk)
    @(negedge clk)
    clr           = 1'b0;
    coeff_valid   = 1'b1;
    $readmemh("../matlab/filter_coeffs/coeff_lpf.txt", coeff_in);
    coeff_valid   = 1'b0;
    end
  endtask

  //------------------------------------------------------------
  // Task to write HPF coefficient of FIR filter
  //------------------------------------------------------------
  task wr_hpf_coeff;
    begin
    @(posedge clk)
    @(negedge clk)
    clr           = 1'b1;
    @(posedge clk)
    @(negedge clk)
    clr           = 1'b0;
    coeff_valid   = 1'b1;
    $readmemh("../matlab/filter_coeffs/coeff_hpf.txt", coeff_in);
    coeff_valid   = 1'b0;
    end
  endtask

  //------------------------------------------------------------
  // Task to write BPF coefficient of FIR filter
  //------------------------------------------------------------
  task wr_bpf_coeff;
    begin
    @(posedge clk)
    @(negedge clk)
    clr           = 1'b1;
    @(posedge clk)
    @(negedge clk)
    clr           = 1'b0;
    coeff_valid   = 1'b1;
    $readmemh("../matlab/filter_coeffs/coeff_bpf.txt", coeff_in);
    coeff_valid   = 1'b0;
    end
  endtask

  //------------------------------------------------------------
  // Task to write input samples to the FIR filter
  //------------------------------------------------------------
  task insert_samples;
    begin
    @(posedge clk)
    @(negedge clk)
    $readmemb("../matlab/samples/mem.txt", samples);
    for (integer i=0; i<2000; i++)
    begin
      @(negedge clk)
      fir_in =  samples[i];
    end
    @(posedge clk)
    @(negedge clk)
    fir_in =  '0;
    repeat(2*N_TAPS)
    begin
      @(negedge clk);
    end
    end
  endtask

  //------------------------------------------------------------
  // Procedure to prevent endless runtime
  //------------------------------------------------------------
  initial
  begin
    #10000000000;
    $display("Runtime Exceeded");
    $finish;
  end

endmodule
