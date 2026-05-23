module top (
    input  wire clk,      // 27 MHz onboard clock
    input  wire key1,     // Button 1 (Hold to Count)
    input  wire key2,     // Button 2 (Hold to Reset)
    output wire [5:0] led // 6 Onboard LEDs
);

    // -----------------------------------------------------------
    // 1. DEBOUNCE BOTH BUTTONS (Keeps the signals perfectly clean)
    // -----------------------------------------------------------
    wire hold_count;
    wire hold_reset;

    debouncer db_count (
        .clk(clk),
        .btn_in(~key1),
        .btn_out(hold_count)
    );

    debouncer db_reset (
        .clk(clk),
        .btn_in(~key2),
        .btn_out(hold_reset)
    );

    // -----------------------------------------------------------
    // 2. THE PRESCALER (Slowing down 27 MHz to human speeds)
    // -----------------------------------------------------------
    // 27,000,000 / 4 = 6,750,000 (roughly 4 ticks per second)
    // We need 23 bits to store a number that large (2^23 = 8,388,608)
    reg [22:0] slow_timer = 0;
    wire slow_tick = (slow_timer == 23'd6_750_000);

    always @(posedge clk) begin
        if (slow_tick) begin
            slow_timer <= 0; // Reset the timer when it hits the target
        end else begin
            slow_timer <= slow_timer + 1'b1; // Keep counting up
        end
    end

    // -----------------------------------------------------------
    // 3. THE 6-BIT COUNTER & RESET LOGIC
    // -----------------------------------------------------------
    reg [5:0] count = 6'd0;

    always @(posedge clk) begin
        // PRIORITY 1: The Reset Button
        // We put this first. If it is held, nothing else matters.
        if (hold_reset) begin
            count <= 6'd0;
        end
        
        // PRIORITY 2: The Count Button + The Slow Tick
        // It will only add 1 if the button is held AND the slow timer ticks
        else if (hold_count && slow_tick) begin
            count <= count + 1'b1;
        end
    end

    // -----------------------------------------------------------
    // 4. OUTPUT
    // -----------------------------------------------------------
    assign led = ~count; // Invert for active-low LEDs

endmodule


// ===============================================================
// REUSABLE SUB-MODULE: Button Debouncer
// ===============================================================
module debouncer (
    input  wire clk,
    input  wire btn_in,
    output reg  btn_out
);
    reg sync_0, sync_1;
    reg [19:0] counter;

    always @(posedge clk) begin
        sync_0 <= btn_in;
        sync_1 <= sync_0;

        if (sync_1 == btn_out) begin
            counter <= 0;
        end else begin
            counter <= counter + 1'b1;
            if (counter == 20'hFFFFF) begin
                btn_out <= sync_1;
            end
        end
    end
endmodule