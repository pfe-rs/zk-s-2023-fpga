
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module projekat(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		          	   	VGA_BLANK_N,
	output		    reg [7:0]		VGA_B,
	output		            		VGA_CLK,
	output		    reg [7:0]		VGA_G,
	output		    reg      		VGA_HS,
	output		    reg [7:0]		VGA_R,
	output		             		VGA_SYNC_N,
	output		    reg      		VGA_VS
);



//=======================================================
//  REG/WIRE declarations
//=======================================================
	reg [20:0] brojac = 0;
	reg [10:0] hBrojac = 0;
	reg [8:0] pokret = 0;
	reg [1:0] k = 1;
	reg [8:0] g = 0;
	reg [10:0] lgranica = 0;
	reg [20:0] dgranica = 0;
	reg [2:0] kliknuto = 0;

//=======================================================
//  Structural coding
//=======================================================

	// postavljanje VGA clock-a
	
	assign VGA_CLK = CLOCK_50;
	assign VGA_SYNC_N = 0;
	assign VGA_BLANK_N = 1;
	
	// frekvencija osvezavanja ekrana je 72Hz
	// rezolucija je 800 x 600
	
	
	// clock je 50mhz => svaki puls traje 0.02 * 10^(-6)s
	always @(posedge CLOCK_50) begin
		brojac = brojac + 1;
		
		if (brojac == 692640) begin
			brojac = 0;
			if (pokret > 255 || pokret < 0) begin
				k = -k;
			end
			pokret = pokret + k;
		end
		
		hBrojac = brojac % 1040;
		
		// HORIZONTAL TIMING
		if (hBrojac >= 0 && hBrojac < 800) begin
			
			// visible area
			
			VGA_R = 8'd250;
			g = (255 - (hBrojac >> 2) + pokret) ;
			if (g > 255 && g <= 510) begin
				g = 510 - g;
			end
			else begin
				if (g > 510) begin
					g = g - 510;
				end
			end
			VGA_G = g;
			VGA_B = 8'd80;
			
			// lgranica => offset za crtanje pravougaonika po X osi
			// dgranica => offset za crtanje pravougaonika po Y osi
			if (hBrojac >= 200 + lgranica && hBrojac < 600 + lgranica && brojac >= 24100 + dgranica && brojac < 546120 + dgranica) begin
				VGA_R = 0;
				VGA_G = 0;
				VGA_B = 0;
				
				// promenljiva kliknuto koristi se kako bismo se osigurali
				// da se kvadrat pomeri samo jednom za jedan pritisak tastera
				
				// ukoliko se ne implementira ovakav sistem
				// kvadrat ce se pomeriti za 7px svakog puta
				// kada okine clock a dugme je pritisnuto (izuzetno cesto)
				if (KEY == 15) begin
					kliknuto = 0;
				end
				
				else if (KEY == 14 && kliknuto == 0) begin
					kliknuto = 1;
					lgranica = lgranica + 7;
				end
				else if (KEY == 7 && kliknuto == 0) begin
					kliknuto = 1;
					lgranica = lgranica - 7;
				end
				
				else if (KEY == 11 && kliknuto == 0) begin
					kliknuto = 1;
					dgranica = dgranica + 1320;
				end
				else if (KEY == 13 && kliknuto == 0) begin
					kliknuto = 1;
					dgranica = dgranica - 1320;
				end
			end
		end
		if (hBrojac >= 800 && hBrojac < 856) begin
			// front porch
			
			VGA_R = 8'd0;
			VGA_G = 8'd0;
			VGA_B = 8'd0;
		end
		if(hBrojac >= 856 && hBrojac < 976) begin
			// sync pulse
			
			// active low => 0 = ON
			VGA_HS = 1;
		end
		if (hBrojac >= 976 && hBrojac < 1040) begin
			// back porch 
			VGA_HS = 0;
			
			VGA_R = 0;
			VGA_G = 0;
			VGA_B = 0;
		end
		
		// VERTICAL TIMING
		if (brojac >= 0 && brojac < 624000) begin
			// visible area
		end
		if (brojac >= 624000 && brojac < 662480) begin
			// front porch
		end
		if (brojac >= 662480 && brojac < 668720) begin
			// sync pulse
			
			VGA_VS = 1;
		end
		if (brojac >= 668720 && brojac < 692640) begin
			// back porch
			VGA_VS = 0;
		end
	end
endmodule