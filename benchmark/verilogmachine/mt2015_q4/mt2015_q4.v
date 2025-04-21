
module top_module(
    input x,
    input y,
    output z
);

    // Define the internal signals
    wire first_gate_output;
    wire second_gate_output;

    // First gate: AND gate with inputs x and y
    and first_gate (
        .a(x),
        .b(y),
        .y(first_gate_output)
    );

    // Second gate: AND gate with inputs y and x
    and second_gate (
        .a(y),
        .b(x),
        .y(second_gate_output)
    );

    // Third gate: OR gate with inputs from the first and second gates
    or third_gate (
        .a(first_gate_output),
        .b(second_gate_output),
        .y(z)
    );

endmodule
