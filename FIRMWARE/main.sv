// currently sythesises properly, should show test frame of borders with a cross
// todo: implement frame display over uart, assuming display works properly
// need to test irl to know for sure

module hub75_controller (
	input	logic		clk_48m,
	input	logic		reset_n,
	output	logic [15:0]	rgb_data,
	output	logic [4:0]	addr,
	output	logic		oe_n,
	output	logic		clk_out,
	output	logic		lat
);

	parameter	CLK_DIV		= 1;
	parameter	ROW_TIME	= 960000;

	logic [31:0]	row_timer;
	logic [4:0]	current_row;
	logic [2:0]	clk_count;
	logic		latch_cycle;
	logic [3:0]	latch_count;
	logic [6:0]	pixel_col;
	logic [3:0]	bit_count;
	logic		clk_reg;
	logic [15:0]	shift_reg;
	logic [3:0]	bit_count_shift;

	always_ff @(posedge clk_48m or negedge reset_n) begin
		if (!reset_n) begin
			clk_count	<= 0;
			clk_reg		<= 0;
		end else begin
			clk_count	<= clk_count + 1'b1;
			if (clk_count == CLK_DIV) begin
				clk_reg		<= ~clk_reg;
				clk_count	<= 0;
			end
		end
	end

	always_ff @(posedge clk_48m or negedge reset_n) begin
		if (!reset_n) begin
			row_timer	<= 0;
			current_row	<= 0;
			pixel_col	<= 0;
		end else begin
			if (row_timer < ROW_TIME - 1) begin
				row_timer <= row_timer + 1;
				if (clk_reg && !latch_cycle && (clk_count == CLK_DIV)) begin
					pixel_col <= pixel_col + 1;
				end
			end else begin
				row_timer	<= 0;
				current_row	<= current_row + 1;
				pixel_col	<= 0;
			end
		end
	end

	always_ff @(posedge clk_48m or negedge reset_n) begin
		if (!reset_n) begin
			latch_cycle	<= 0;
			latch_count	<= 0;
		end else begin
			if (row_timer == ROW_TIME - 1) begin
				latch_cycle	<= 1;
				latch_count	<= 0;
			end else if (latch_cycle) begin
				if (latch_count < 15) begin
					latch_count <= latch_count + 1;
				end else begin
					latch_cycle <= 0;
				end
			end
		end
	end

	logic [15:0] framebuffer [0:8191];

  // test frame
	initial begin
		int i;
		for (i = 0; i < 8192; i = i + 1) begin
			framebuffer[i] = 16'h0000;
		end
		for (i = 0; i < 128; i = i + 1) begin
			framebuffer[i] = 16'hFFFF;
			framebuffer[8191 - i] = 16'hFFFF;
		end
		for (i = 0; i < 64; i = i + 1) begin
			framebuffer[i * 128] = 16'hFFFF;
			framebuffer[i * 128 + 127] = 16'hFFFF;
		end
		for (i = 0; i < 128; i = i + 1) begin
			framebuffer[32 * 128 + i] = 16'hFFFF;
		end
		for (i = 0; i < 64; i = i + 1) begin
			framebuffer[i * 128 + 64] = 16'hFFFF;
		end
	end

	logic [15:0] pixel_data;
	assign pixel_data = framebuffer[current_row * 128 + pixel_col];

	always_ff @(posedge clk_48m or negedge reset_n) begin
		if (!reset_n) begin
			shift_reg		<= 0;
			bit_count_shift	<= 0;
		end else if (clk_reg && !latch_cycle) begin
			if (bit_count_shift < 15) begin
				shift_reg <= {shift_reg[14:0], pixel_data[15 - bit_count_shift]};
				bit_count_shift <= bit_count_shift + 1;
			end else begin
				shift_reg <= {shift_reg[14:0], pixel_data[0]};
				bit_count_shift <= 0;
			end
		end else if (latch_cycle && !clk_reg) begin
			shift_reg		<= pixel_data;
			bit_count_shift	<= 0;
		end
	end

	assign addr		= current_row;
	assign clk_out	= clk_reg;
	assign lat		= latch_cycle;
	assign oe_n		= ~(row_timer < ROW_TIME - 2000);
	assign rgb_data	= shift_reg;

endmodule
