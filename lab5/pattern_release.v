/*
    @debug method : dump file
        
    @description :
        
    @issue :
        
    @todo :
        
*/

/*`ifdef RTL
    `define CYCLE_TIME 10.0
`endif
`ifdef GATE
    `define CYCLE_TIME 10.0
`endif
`ifdef POST
    `define CYCLE_TIME 10.0
`endif

module PATTERN(
    // Output signals
    clk,
	rst_n,
	
	in_valid,
	in_valid2,
	
    image,
	template,
	image_size,
	action,

    // Input signals
	out_valid,
	out_value
);

//======================================
//      INPUT & OUTPUT
//======================================
// Output
output reg       clk, rst_n;
output reg       in_valid;
output reg       in_valid2;

output reg [7:0] image;
output reg [7:0] template;
output reg [1:0] image_size;
output reg [2:0] action;

// Input
input out_valid;
input out_value;

//======================================
//      PARAMETERS & VARIABLES
//======================================
//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Can be modified by user
integer   TOTAL_PATNUM = 500;
integer   SIMPLE_PATNUM = 10;
integer   SEED = 54871;
parameter DEBUG = 1;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
integer   SETNUM = 8;
parameter CYCLE = `CYCLE_TIME;
parameter DELAY = 5000;
parameter OUTBIT = 20;
integer   OUTNUM = -1;

// PATTERN CONTROL
integer stop;
integer set;
integer pat;
integer exe_lat;
integer out_lat;
integer out_check_idx;
integer tot_lat;
integer input_delay;
integer each_delay;

// FILE CONTROL
integer file;
integer file_out;

// String control
// Should use %0s
reg[9*8:1]  reset_color       = "\033[1;0m";
reg[10*8:1] txt_black_prefix  = "\033[1;30m";
reg[10*8:1] txt_red_prefix    = "\033[1;31m";
reg[10*8:1] txt_green_prefix  = "\033[1;32m";
reg[10*8:1] txt_yellow_prefix = "\033[1;33m";
reg[10*8:1] txt_blue_prefix   = "\033[1;34m";

reg[10*8:1] bkg_black_prefix  = "\033[40;1m";
reg[10*8:1] bkg_red_prefix    = "\033[41;1m";
reg[10*8:1] bkg_green_prefix  = "\033[42;1m";
reg[10*8:1] bkg_yellow_prefix = "\033[43;1m";
reg[10*8:1] bkg_blue_prefix   = "\033[44;1m";
reg[10*8:1] bkg_white_prefix  = "\033[47;1m";

//======================================
//      DATA MODEL
//======================================
// Image & Template
parameter NUM_OF_CHANNEL = 3; // red, green, blue
parameter MAX_SIZE_OF_IMAGE = 16;
parameter SIZE_OF_TEMPLATE = 3;
// Action
parameter MIN_SIZE_OF_ACTION = 2;
parameter MAX_SIZE_OF_ACTION = 8;
parameter NUM_OF_FIRST_ACTION_TYPE = 3;
parameter LAST_ACTION_TYPE = 7;
// Operation
parameter SIZE_OF_MAXPOOL_WINDOW = 2;
parameter SIZE_OF_FILTER_WINDOW = 3;
parameter SIZE_OF_PAD_WINDOW = 2;
// Input
reg[7:0] _image[NUM_OF_CHANNEL-1:0][MAX_SIZE_OF_IMAGE-1:0][MAX_SIZE_OF_IMAGE-1:0];
reg[7:0] _template[SIZE_OF_TEMPLATE-1:0][SIZE_OF_TEMPLATE-1:0];
reg[2:0] _actionList[MAX_SIZE_OF_ACTION-1:0];
integer _imageSizeBit;
integer _imageSize;
integer _actionListSize;

// Intermediate output
reg[OUTBIT-1:0] _intermediate[MAX_SIZE_OF_ACTION-1:0][MAX_SIZE_OF_IMAGE-1:0][MAX_SIZE_OF_IMAGE-1:0];
integer _intermediateSize[MAX_SIZE_OF_ACTION-1:0];

// Design output
reg[OUTBIT-1:0] _your[MAX_SIZE_OF_IMAGE-1:0][MAX_SIZE_OF_IMAGE-1:0];
integer _outputSize;

//
// Clear
//
task clear_input;
    integer _channel;
    integer _row;
    integer _col;
begin
    for(_channel=0 ; _channel<NUM_OF_CHANNEL ; _channel=_channel+1) begin
        for(_row=0 ; _row<MAX_SIZE_OF_IMAGE ; _row=_row+1) begin
            for(_col=0 ; _col<MAX_SIZE_OF_IMAGE ; _col=_col+1) begin
                _image[_channel][_row][_col] = 'dx;
            end
        end
    end
    for(_row=0 ; _row<SIZE_OF_TEMPLATE ; _row=_row+1) begin
        for(_col=0 ; _col<SIZE_OF_TEMPLATE ; _col=_col+1) begin
            _template[_row][_col] = 'dx;
        end
    end
end endtask

task clear_intermediate;
    integer _actIdx;
    integer _row;
    integer _col;
begin
    for(_actIdx=0 ; _actIdx<MAX_SIZE_OF_ACTION ; _actIdx=_actIdx+1) begin
        // intermediate size
        _intermediateSize[_actIdx] = 0;
        // intermediate figure
        for(_row=0 ; _row<MAX_SIZE_OF_IMAGE ; _row=_row+1) begin
            for(_col=0 ; _col<MAX_SIZE_OF_IMAGE ; _col=_col+1) begin
                _intermediate[_actIdx][_row][_col] = 'dx;
            end
        end
        // action size
        _actionListSize = 0;
        // action
        _actionList[_actIdx] = 'dx;
    end
end endtask

task clear_your_answer;
    integer _row;
    integer _col;
begin
    for(_row=0 ; _row<MAX_SIZE_OF_IMAGE ; _row=_row+1) begin
        for(_col=0 ; _col<MAX_SIZE_OF_IMAGE ; _col=_col+1) begin
            _your[_row][_col] = 'dx;
        end
    end
end endtask

//
// Operation
//
task run_action;
    input integer _actIdx;
    input reg[2:0] _actType;
begin
    case(_actType)
        'd0: gray_transf_max_intermediate(_actIdx);
        'd1: gray_transf_avg_intermediate(_actIdx);
        'd2: gray_transf_wght_intermediate(_actIdx);
        'd3: max_pool_intermediate(_actIdx);
        'd4: negative_intermediate(_actIdx);
        'd5: horiz_flip_intermediate(_actIdx);
        'd6: img_filter_intermediate(_actIdx);
        'd7: cross_corr_intermediate(_actIdx);
        default: begin
            $display("[ERROR] [Run Action] Error action type...");
            $finish;
        end
    endcase
end endtask

task gray_transf_max_intermediate;
    input integer _actIdx;
    integer _row;
    integer _col;
    integer _channel;
    integer _max;
begin
    // size
    _intermediateSize[_actIdx] = _imageSize;
    // intermediate figure
    for(_row=0 ; _row<_intermediateSize[_actIdx] ; _row=_row+1) begin
        for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) begin
            _max = 0;
            for(_channel=0 ; _channel<NUM_OF_CHANNEL ; _channel=_channel+1) begin
                _max =
                    (_max>_image[_channel][_row][_col])
                    ? _max
                    : _image[_channel][_row][_col];
            end
            _intermediate[_actIdx][_row][_col] =_max;
        end
    end
end endtask

task gray_transf_avg_intermediate;
    input integer _actIdx;
    integer _row;
    integer _col;
begin
    // size
    _intermediateSize[_actIdx] = _imageSize;
    // intermediate figure
    for(_row=0 ; _row<_intermediateSize[_actIdx] ; _row=_row+1) begin
        for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) begin
            _intermediate[_actIdx][_row][_col] =
                $floor(
                    (_image[0][_row][_col]+
                    _image[1][_row][_col]+
                    _image[2][_row][_col])/3
                );
        end
    end
end endtask

task gray_transf_wght_intermediate;
    input integer _actIdx;
    integer _row;
    integer _col;
begin
    // size
    _intermediateSize[_actIdx] = _imageSize;
    // intermediate figure
    for(_row=0 ; _row<_intermediateSize[_actIdx] ; _row=_row+1) begin
        for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) begin
            _intermediate[_actIdx][_row][_col] =
                _image[0][_row][_col]/4+
                _image[1][_row][_col]/2+
                _image[2][_row][_col]/4;
        end
    end
end endtask

task max_pool_intermediate;
    input integer _actIdx;
    integer _row;
    integer _col;
    integer _pool_row;
    integer _pool_col;
    integer _tmp;
begin
    if(_intermediateSize[_actIdx-1]===4) begin
        // size
        _intermediateSize[_actIdx] = _intermediateSize[_actIdx-1];
        // intermediate figure
        for(_row=0 ; _row<_intermediateSize[_actIdx] ; _row=_row+1) begin
            for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) begin
                _intermediate[_actIdx][_row][_col] = 
                    _intermediate[_actIdx-1][_row][_col];
            end
        end
    end
    else begin
        // size
        _intermediateSize[_actIdx] = _intermediateSize[_actIdx-1]/SIZE_OF_MAXPOOL_WINDOW;
        // intermediate figure
        for(_row=0 ; _row<_intermediateSize[_actIdx-1] ; _row=_row+SIZE_OF_MAXPOOL_WINDOW) begin
            for(_col=0 ; _col<_intermediateSize[_actIdx-1] ; _col=_col+SIZE_OF_MAXPOOL_WINDOW) begin
                _tmp = _intermediate[_actIdx-1][_row][_col];
                for(_pool_row=0 ; _pool_row<SIZE_OF_MAXPOOL_WINDOW ; _pool_row=_pool_row+1) begin
                    for(_pool_col=0 ; _pool_col<SIZE_OF_MAXPOOL_WINDOW ; _pool_col=_pool_col+1) begin
                        _tmp =
                            (_tmp>_intermediate[_actIdx-1][_row+_pool_row][_col+_pool_col])
                            ? _tmp
                            : _intermediate[_actIdx-1][_row+_pool_row][_col+_pool_col];
                    end
                end
                _intermediate[_actIdx][_row/SIZE_OF_MAXPOOL_WINDOW][_col/SIZE_OF_MAXPOOL_WINDOW] = _tmp;
            end
        end
    end
end endtask

task negative_intermediate;
    input integer _actIdx;
    integer _row;
    integer _col;
begin
    // size
    _intermediateSize[_actIdx] = _intermediateSize[_actIdx-1];
    // intermediate figure
    for(_row=0 ; _row<_intermediateSize[_actIdx] ; _row=_row+1) begin
        for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) begin
            _intermediate[_actIdx][_row][_col] =
                255 - _intermediate[_actIdx-1][_row][_col];
        end
    end
end endtask

task horiz_flip_intermediate;
    input integer _actIdx;
    integer _row;
    integer _col;
begin
    // size
    _intermediateSize[_actIdx] = _intermediateSize[_actIdx-1];
    // intermediate figure
    for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) begin
        for(_row=0 ; _row<_intermediateSize[_actIdx] ; _row=_row+1) begin
            _intermediate[_actIdx][_row][_col] = _intermediate[_actIdx-1][_row][_intermediateSize[_actIdx]-_col-1];
        end
    end
end endtask

task img_filter_intermediate;
    input integer _actIdx;
    integer _row;
    integer _col;
    integer _innerRow;
    integer _innerCol;

    integer _sizeOfPad;
    reg[OUTBIT-1:0] _padding[MAX_SIZE_OF_IMAGE+SIZE_OF_PAD_WINDOW-1:0][MAX_SIZE_OF_IMAGE+SIZE_OF_PAD_WINDOW-1:0];
    reg[OUTBIT-1:0] _temp[SIZE_OF_FILTER_WINDOW*SIZE_OF_FILTER_WINDOW-1:0];
begin
    // size
    _intermediateSize[_actIdx] = _intermediateSize[_actIdx-1];

    // padding - replication
    _sizeOfPad = _intermediateSize[_actIdx]+SIZE_OF_PAD_WINDOW;
    for(_col=0 ; _col<MAX_SIZE_OF_IMAGE+SIZE_OF_PAD_WINDOW ; _col=_col+1) begin
        for(_row=0 ; _row<MAX_SIZE_OF_IMAGE+SIZE_OF_PAD_WINDOW ; _row=_row+1) begin
            _padding[_row][_col] = 0;
        end
    end
    for(_row=0 ; _row<_intermediateSize[_actIdx-1] ; _row=_row+1) begin
        for(_col=0 ; _col<_intermediateSize[_actIdx-1] ; _col=_col+1) begin
            _padding[_row+1][_col+1] = _intermediate[_actIdx-1][_row][_col];
        end
    end
    for(_row=1 ; _row<_sizeOfPad-1 ; _row=_row+1) begin
        _padding[_row][0] = _intermediate[_actIdx-1][_row-1][0];
        _padding[_row][_sizeOfPad-1] = _intermediate[_actIdx-1][_row-1][_intermediateSize[_actIdx-1]-1];
    end
    for(_col=1 ; _col<_sizeOfPad-1 ; _col=_col+1) begin
        _padding[0][_col] = _intermediate[_actIdx-1][0][_col-1];
        _padding[_sizeOfPad-1][_col] = _intermediate[_actIdx-1][_intermediateSize[_actIdx-1]-1][_col-1];
    end

    _padding[0][0] = _intermediate[_actIdx-1][0][0];
    _padding[0][_sizeOfPad-1] = _intermediate[_actIdx-1][0][_intermediateSize[_actIdx-1]-1];
    _padding[_sizeOfPad-1][0] = _intermediate[_actIdx-1][_intermediateSize[_actIdx-1]-1][0];
    _padding[_sizeOfPad-1][_sizeOfPad-1] = _intermediate[_actIdx-1][_intermediateSize[_actIdx-1]-1][_intermediateSize[_actIdx-1]-1];

    // intermediate figure
    for(_row=0 ; _row<_intermediateSize[_actIdx] ; _row=_row+1) begin
        for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) begin
            for(_innerRow=0 ; _innerRow<SIZE_OF_FILTER_WINDOW ; _innerRow=_innerRow+1) begin
                for(_innerCol=0 ; _innerCol<SIZE_OF_FILTER_WINDOW ; _innerCol=_innerCol+1) begin
                    _temp[_innerRow*SIZE_OF_FILTER_WINDOW+_innerCol] = _padding[_row+_innerRow][_col+_innerCol];
                end
            end
            _intermediate[_actIdx][_row][_col] = findeMedian(_temp);
        end
    end

end endtask

task cross_corr_intermediate;
    input integer _actIdx;
    integer _row;
    integer _col;
    integer _innerRow;
    integer _innerCol;

    integer _sizeOfPad;
    reg[OUTBIT-1:0] _padding[MAX_SIZE_OF_IMAGE+SIZE_OF_PAD_WINDOW-1:0][MAX_SIZE_OF_IMAGE+SIZE_OF_PAD_WINDOW-1:0];
    reg[OUTBIT-1:0] _sum;
begin
    // size
    _intermediateSize[_actIdx] = _intermediateSize[_actIdx-1];

    // padding - zero padding
    _sizeOfPad = _intermediateSize[_actIdx]+SIZE_OF_PAD_WINDOW;
    for(_col=0 ; _col<MAX_SIZE_OF_IMAGE+SIZE_OF_PAD_WINDOW ; _col=_col+1) begin
        for(_row=0 ; _row<MAX_SIZE_OF_IMAGE+SIZE_OF_PAD_WINDOW ; _row=_row+1) begin
            _padding[_row][_col] = 0;
        end
    end
    for(_row=0 ; _row<_intermediateSize[_actIdx-1] ; _row=_row+1) begin
        for(_col=0 ; _col<_intermediateSize[_actIdx-1] ; _col=_col+1) begin
            _padding[_row+1][_col+1] = _intermediate[_actIdx-1][_row][_col];
        end
    end
    
    // intermediate figure
    for(_row=0 ; _row<_intermediateSize[_actIdx] ; _row=_row+1) begin
        for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) begin
            _sum = 0;
            for(_innerRow=0 ; _innerRow<SIZE_OF_TEMPLATE ; _innerRow=_innerRow+1) begin
                for(_innerCol=0 ; _innerCol<SIZE_OF_TEMPLATE ; _innerCol=_innerCol+1) begin
                    _sum = _sum 
                        + _padding[_row+_innerRow][_col+_innerCol] * _template[_innerRow][_innerCol];
                end
            end
            _intermediate[_actIdx][_row][_col] = _sum;
        end
    end

end endtask

//
// Generate input
//
task randomize_figure;
    integer _channel;
    integer _row;
    integer _col;
begin
    _imageSizeBit = {$random(SEED)} % 3;
    _imageSize = 2 ** (_imageSizeBit + 2);
    for(_channel=0 ; _channel<NUM_OF_CHANNEL ; _channel=_channel+1) begin
        for(_row=0 ; _row<_imageSize ; _row=_row+1) begin
            for(_col=0 ; _col<_imageSize ; _col=_col+1) begin
                _image[_channel][_row][_col] = (pat<SIMPLE_PATNUM)
                    ? {$random(SEED)} % 10
                    : {$random(SEED)} % 256;
            end
        end
    end
    for(_row=0 ; _row<SIZE_OF_TEMPLATE ; _row=_row+1) begin
        for(_col=0 ; _col<SIZE_OF_TEMPLATE ; _col=_col+1) begin
            _template[_row][_col] = (pat<SIMPLE_PATNUM)
                ? {$random(SEED)} % 5
                : {$random(SEED)} % 256;
        end
    end
end endtask

task randomize_action;
    integer _actIdx;
begin
    _actionListSize = {$random(SEED)} % (MAX_SIZE_OF_ACTION - MIN_SIZE_OF_ACTION + 1) + MIN_SIZE_OF_ACTION;
    _actionList[0] = {$random(SEED)} % NUM_OF_FIRST_ACTION_TYPE;
    for(_actIdx=1 ; _actIdx<_actionListSize ; _actIdx=_actIdx+1)begin
        _actionList[_actIdx] = {$random(SEED)} % (LAST_ACTION_TYPE - NUM_OF_FIRST_ACTION_TYPE) + NUM_OF_FIRST_ACTION_TYPE;
    end
    _actionList[_actionListSize-1] = LAST_ACTION_TYPE;
end endtask

//
// Dump
//
reg[4*8:1] _lineSize4  = "____";
reg[4*8:1] _spaceSize4 = "    ";
reg[9*8:1] _lineSize9  = "_________";
reg[9*8:1] _spaceSize9 = "         ";
task clear_file; begin
    file_out = $fopen("input.txt", "w");
    $fclose(file_out);
    file_out = $fopen("output.txt", "w");
    $fclose(file_out);
end endtask

task dump_input;
    integer _channel;
    integer _row;
    integer _col;
begin
    file_out = $fopen("input.txt", "w");

    $fwrite(file_out, "[PAT NO. %4d]\n\n", pat);
    $fwrite(file_out, "[set # %1d]\n\n", set);

    $fwrite(file_out, "[=======]\n");
    $fwrite(file_out, "[ Image ]\n");
    $fwrite(file_out, "[=======]\n\n");
    $fwrite(file_out, "[image_size / size] : %1d / %2d\n\n", _imageSizeBit, _imageSize);
    $fwrite(file_out, "[0] : R\n");
    $fwrite(file_out, "[1] : G\n");
    $fwrite(file_out, "[2] : B\n\n");

    // [#0] **1 **2 **3
    // _________________
    //   0| **1 **2 **3
    //   1| **1 **2 **3
    //   2| **1 **2 **3

    // [#0] **1 **2 **3
    for(_channel=0 ; _channel<NUM_OF_CHANNEL ; _channel=_channel+1) begin
        $fwrite(file_out, "[%1d] ", _channel);
        for(_col=0 ; _col<_imageSize ; _col=_col+1) $fwrite(file_out, "%3d ",_col);
        $fwrite(file_out, "%0s", _spaceSize4);
    end
    $fwrite(file_out, "\n");
    // _________________
    for(_channel=0 ; _channel<NUM_OF_CHANNEL ; _channel=_channel+1) begin
        $fwrite(file_out, "%0s", _lineSize4);
        for(_col=0 ; _col<_imageSize ; _col=_col+1) $fwrite(file_out, "%0s", _lineSize4);
        $fwrite(file_out, "%0s", _spaceSize4);
    end
    $fwrite(file_out, "\n");
    //   0| **1 **2 **3
    for(_row=0 ; _row<_imageSize ; _row=_row+1) begin
        for(_channel=0 ; _channel<NUM_OF_CHANNEL ; _channel=_channel+1) begin
            $fwrite(file_out, "%2d| ",_row);
            for(_col=0 ; _col<_imageSize ; _col=_col+1) begin
                $fwrite(file_out, "%3d ", _image[_channel][_row][_col]);
            end
            $fwrite(file_out, "%0s", _spaceSize4);
        end
        $fwrite(file_out, "\n");
    end
    $fwrite(file_out, "\n");

    $fwrite(file_out, "[==========]\n");
    $fwrite(file_out, "[ Template ]\n");
    $fwrite(file_out, "[==========]\n\n");
    
    // [#0] **1 **2 **3
    $fwrite(file_out, "[ ] ");
    for(_col=0 ; _col<SIZE_OF_TEMPLATE ; _col=_col+1) $fwrite(file_out, "%3d ",_col);
    $fwrite(file_out, "%0s", _spaceSize4);
    $fwrite(file_out, "\n");
    // _________________
    $fwrite(file_out, "%0s", _lineSize4);
    for(_col=0 ; _col<SIZE_OF_TEMPLATE ; _col=_col+1) $fwrite(file_out, "%0s", _lineSize4);
    $fwrite(file_out, "%0s", _spaceSize4);
    $fwrite(file_out, "\n");
    //   0| **1 **2 **3
    for(_row=0 ; _row<SIZE_OF_TEMPLATE ; _row=_row+1) begin
        $fwrite(file_out, "%2d| ",_row);
        for(_col=0 ; _col<SIZE_OF_TEMPLATE ; _col=_col+1) begin
            $fwrite(file_out, "%3d ", _template[_row][_col]);
        end
        $fwrite(file_out, "%0s", _spaceSize4);
        $fwrite(file_out, "\n");
    end
    $fwrite(file_out, "\n");

    $fclose(file_out);
end endtask

function [20*8:1] getActionName;
    input [2:0] _actIn;
begin
    getActionName = "None";
    case(_actIn)
        'd0: getActionName = "Grayscale - max";
        'd1: getActionName = "Grayscale - average";
        'd2: getActionName = "Grayscale - weighted";
        'd3: getActionName = "Max pooling";
        'd4: getActionName = "Negative";
        'd5: getActionName = "Horizontal flip";
        'd6: getActionName = "Image filter";
        'd7: getActionName = "Cross correlation";
        default: begin
            $display("[ERROR] [Run Action] Error action type...");
            $finish;
        end
    endcase
end endfunction

task dump_output;
    integer _actIdx;
    integer _row;
    integer _col;
begin
    file_out = $fopen("output.txt", "w");

    $fwrite(file_out, "[========]\n");
    $fwrite(file_out, "[ Action ]\n");
    $fwrite(file_out, "[========]\n\n");
    $fwrite(file_out, "[Num of action] : %1d\n\n", _actionListSize);
    for(_actIdx=0 ; _actIdx<_actionListSize ; _actIdx=_actIdx+1) begin
        $fwrite(file_out, "[%1d] - %0s\n", _actIdx, getActionName(_actionList[_actIdx]));
    end
    $fwrite(file_out, "\n");

    // [#0] **1 **2 **3
    // _________________
    //   0| **1 **2 **3
    //   1| **1 **2 **3
    //   2| **1 **2 **3

    $fwrite(file_out, "[=====================]\n");
    $fwrite(file_out, "[ Intermediate Output ]\n");
    $fwrite(file_out, "[=====================]\n\n");
    for(_actIdx=0 ; _actIdx<_actionListSize ; _actIdx=_actIdx+1) begin
        $fwrite(file_out, "[action] : %0s\n", getActionName(_actionList[_actIdx]));
        $fwrite(file_out, "[size  ] : %2d\n\n", _intermediateSize[_actIdx]);
        // [#0] **1 **2 **3
        $fwrite(file_out, "[%1d] ", _actIdx);
        for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) $fwrite(file_out, "%8d ",_col);
        $fwrite(file_out, "%0s", _spaceSize4);
        $fwrite(file_out, "\n");
        // _________________
        $fwrite(file_out, "%0s", _lineSize4);
        for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) $fwrite(file_out, "%0s", _lineSize9);
        $fwrite(file_out, "%0s", _spaceSize4);
        $fwrite(file_out, "\n");
        //   0| **1 **2 **3
        for(_row=0 ; _row<_intermediateSize[_actIdx] ; _row=_row+1) begin
            $fwrite(file_out, "%2d| ",_row);
            for(_col=0 ; _col<_intermediateSize[_actIdx] ; _col=_col+1) begin
                $fwrite(file_out, "%8d ", _intermediate[_actIdx][_row][_col]);
            end
            $fwrite(file_out, "%0s", _spaceSize4);
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "[=============]\n");
    $fwrite(file_out, "[ Your answer ]\n");
    $fwrite(file_out, "[=============]\n\n");
    
    // [#0] **1 **2 **3
    $fwrite(file_out, "[ ] ");
    for(_col=0 ; _col<_outputSize ; _col=_col+1) $fwrite(file_out, "%8d ",_col);
    $fwrite(file_out, "%0s", _spaceSize4);
    $fwrite(file_out, "\n");
    // _________________
    $fwrite(file_out, "%0s", _lineSize4);
    for(_col=0 ; _col<_outputSize ; _col=_col+1) $fwrite(file_out, "%0s", _lineSize9);
    $fwrite(file_out, "%0s", _spaceSize4);
    $fwrite(file_out, "\n");
    //   0| **1 **2 **3
    for(_row=0 ; _row<_outputSize ; _row=_row+1) begin
        $fwrite(file_out, "%2d| ",_row);
        for(_col=0 ; _col<_outputSize ; _col=_col+1) begin
            $fwrite(file_out, "%8d ", _your[_row][_col]);
        end
        $fwrite(file_out, "%0s", _spaceSize4);
        $fwrite(file_out, "\n");
    end
    $fwrite(file_out, "\n");

    $fclose(file_out);
end endtask

//
// Utility
//
function[OUTBIT-1:0] findeMedian;
    input[OUTBIT-1:0] in[SIZE_OF_FILTER_WINDOW*SIZE_OF_FILTER_WINDOW-1:0];

    integer _idx1, _idx2;
    reg[OUTBIT-1:0] sorted[SIZE_OF_FILTER_WINDOW*SIZE_OF_FILTER_WINDOW-1:0];
    reg[OUTBIT-1:0] temp;
begin
    for(_idx1=0; _idx1<9; _idx1=_idx1+1) begin
        sorted[_idx1] = in[_idx1];
    end

    for(_idx1=0; _idx1<SIZE_OF_FILTER_WINDOW*SIZE_OF_FILTER_WINDOW; _idx1=_idx1+1) begin
        for(_idx2=0; _idx2<SIZE_OF_FILTER_WINDOW*SIZE_OF_FILTER_WINDOW-_idx1; _idx2=_idx2+1) begin
            if (sorted[_idx2] > sorted[_idx2+1]) begin
                temp = sorted[_idx2];
                sorted[_idx2] = sorted[_idx2+1];
                sorted[_idx2+1] = temp;
            end
        end
    end
    findeMedian = sorted[SIZE_OF_FILTER_WINDOW*SIZE_OF_FILTER_WINDOW/2];
end endfunction

//======================================
//              MAIN
//======================================
initial exe_task;

//======================================
//              CLOCK
//======================================
initial clk = 1'b0;
always #(CYCLE/2.0) clk = ~clk;

//======================================
//              TASKS
//======================================
task exe_task; begin
    reset_task;
    for(pat=0 ; pat<TOTAL_PATNUM ; pat=pat+1) begin
        reset_figure_task;
        input_figure_task;
        for(set=0 ; set<SETNUM ; set=set+1) begin
            reset_intermediate_task;
            input_action_task;
            cal_task;
            wait_task;
            check_task;
            // Print Pass Info and accumulate the total latency
            $display("%0sPASS PATTERN NO.%4d / Set #%1d %0sCycles: %3d%0s",txt_blue_prefix, pat, set, txt_green_prefix, exe_lat, reset_color);
        end
    end
    pass_task;
end endtask

task reset_task; begin
    force clk = 0;
    rst_n = 1;
    in_valid = 0;
    in_valid2 = 0;
    image = 'dx;
    template = 'dx;
    image_size = 'dx;
    action = 'dx;

    tot_lat = 0;

    #(CYCLE/2.0) rst_n = 0;
    #(CYCLE*2) rst_n = 1;
    if(out_valid !== 0 || out_value !== 0) begin
        $display("[ERROR] [Reset] Output signal should be 0 at %-12d ps  ", $time*1000);
        repeat(5) #(CYCLE);
        $finish;
    end
    #(CYCLE/2.0) rst_n = 1;
    #(CYCLE/2.0) release clk;
end endtask

task reset_figure_task; begin
    clear_input;
    clear_intermediate;
end endtask

task reset_intermediate_task; begin
    clear_intermediate;
    clear_your_answer;
    clear_file;
end endtask

task input_figure_task;
    integer _cnt;
begin
    randomize_figure;
    repeat(({$random(SEED)} % 3 + 2)) @(negedge clk);
    for(_cnt=0 ; _cnt<NUM_OF_CHANNEL*_imageSize*_imageSize ; _cnt=_cnt+1)begin
        in_valid = 1;

        image = _image[_cnt%NUM_OF_CHANNEL][_cnt/(NUM_OF_CHANNEL*_imageSize)][(_cnt/NUM_OF_CHANNEL)%_imageSize];

        if(_cnt < SIZE_OF_TEMPLATE*SIZE_OF_TEMPLATE) template = _template[_cnt/SIZE_OF_TEMPLATE][_cnt%SIZE_OF_TEMPLATE];
        else template = 'dx;

        if(_cnt===0) image_size = _imageSizeBit;
        else image_size = 'dx;

        @(negedge clk);
    end
    in_valid = 0;
    image = 'dx;
    template = 'dx;
    image_size = 'dx;
end endtask

task input_action_task;
    integer _cnt;
begin
    randomize_action;
    repeat(({$random(SEED)} % 3 + 2)) @(negedge clk);
    for(_cnt=0 ; _cnt<_actionListSize ; _cnt=_cnt+1)begin
        in_valid2 = 1;
        action = _actionList[_cnt];
        @(negedge clk);
    end
    in_valid2 = 0;
    action = 'dx;
end endtask

task cal_task;
    integer _actIdx;
begin
    for(_actIdx=0 ; _actIdx<_actionListSize ; _actIdx=_actIdx+1)begin
        run_action(_actIdx, _actionList[_actIdx]);
    end
    _outputSize = _intermediateSize[_actionListSize-1];
    OUTNUM = OUTBIT * _intermediateSize[_actionListSize-1] * _intermediateSize[_actionListSize-1];

    if(DEBUG) begin
        dump_input;
        dump_output;
    end
end endtask

task wait_task; begin
    exe_lat = -1;
    while(out_valid !== 1) begin
        if(out_value !== 0) begin
            $display("[ERROR] [WAIT] Output signal should be 0 at %-12d ps  ", $time*1000);
            repeat(5) @(negedge clk);
            $finish;
        end
        if(exe_lat == DELAY) begin
            $display("[ERROR] [WAIT] The execution latency at %-12d ps is over %5d cycles  ", $time*1000, DELAY);
            repeat(5) @(negedge clk);
            $finish; 
        end
        exe_lat = exe_lat + 1;
        @(negedge clk);
    end
end endtask

task check_task;
    integer _row;
    integer _col;
begin
    out_lat = 0;
    while(out_valid===1) begin
        if(out_lat==OUTNUM) begin
            $display("[ERROR] [OUTPUT] Out cycles is more than %3d at %-12d ps", OUTNUM, $time*1000);
            repeat(5) @(negedge clk);
            $finish;
        end
        
        _your[out_lat/OUTBIT/_outputSize][(out_lat/OUTBIT)%_outputSize][OUTBIT-(out_lat%OUTBIT)-1] = out_value;

        out_lat = out_lat + 1;
        @(negedge clk);
    end
    if(out_lat<OUTNUM) begin
        $display("[ERROR] [OUTPUT] Out cycles is less than %3d at %-12d ps", OUTNUM, $time*1000);
        repeat(5) @(negedge clk);
        $finish;
    end

    //
    // Check
    //
    for(_row=0 ; _row<_outputSize ; _row=_row+1) begin
        for(_col=0 ; _col<_outputSize ; _col=_col+1) begin
            if(_your[_row][_col] !== _intermediate[_actionListSize-1][_row][_col]) begin
                $display("[ERROR] [OUTPUT] Output is not correct...\n");
                $display("[ERROR] [OUTPUT] Dump debugging file...");
                $display("[ERROR] [OUTPUT]      input.tx contains image and template");
                $display("[ERROR] [OUTPUT]      output.tx contains intermediate results and action list\n");
                $display("[ERROR] [OUTPUT] Your pixel is not correct at (%2d, %2d)\n", _row, _col);
                dump_input;
                dump_output;
                repeat(5) @(negedge clk);
                $finish;
            end
        end
    end

    tot_lat = tot_lat + exe_lat;
end endtask

task pass_task; begin
    $display("\033[1;33m                `oo+oy+`                            \033[1;35m Congratulation!!! \033[1;0m                                   ");
    $display("\033[1;33m               /h/----+y        `+++++:             \033[1;35m PASS This Lab........Maybe \033[1;0m                          ");
    $display("\033[1;33m             .y------:m/+ydoo+:y:---:+o             \033[1;35m Total Latency : %-10d\033[1;0m                                ", tot_lat);
    $display("\033[1;33m              o+------/y--::::::+oso+:/y                                                                                     ");
    $display("\033[1;33m              s/-----:/:----------:+ooy+-                                                                                    ");
    $display("\033[1;33m             /o----------------/yhyo/::/o+/:-.`                                                                              ");
    $display("\033[1;33m            `ys----------------:::--------:::+yyo+                                                                           ");
    $display("\033[1;33m            .d/:-------------------:--------/--/hos/                                                                         ");
    $display("\033[1;33m            y/-------------------::ds------:s:/-:sy-                                                                         ");
    $display("\033[1;33m           +y--------------------::os:-----:ssm/o+`                                                                          ");
    $display("\033[1;33m          `d:-----------------------:-----/+o++yNNmms                                                                        ");
    $display("\033[1;33m           /y-----------------------------------hMMMMN.                                                                      ");
    $display("\033[1;33m           o+---------------------://:----------:odmdy/+.                                                                    ");
    $display("\033[1;33m           o+---------------------::y:------------::+o-/h                                                                    ");
    $display("\033[1;33m           :y-----------------------+s:------------/h:-:d                                                                    ");
    $display("\033[1;33m           `m/-----------------------+y/---------:oy:--/y                                                                    ");
    $display("\033[1;33m            /h------------------------:os++/:::/+o/:--:h-                                                                    ");
    $display("\033[1;33m         `:+ym--------------------------://++++o/:---:h/                                                                     ");
    $display("\033[1;31m        `hhhhhoooo++oo+/:\033[1;33m--------------------:oo----\033[1;31m+dd+                                                 ");
    $display("\033[1;31m         shyyyhhhhhhhhhhhso/:\033[1;33m---------------:+/---\033[1;31m/ydyyhs:`                                              ");
    $display("\033[1;31m         .mhyyyyyyhhhdddhhhhhs+:\033[1;33m----------------\033[1;31m:sdmhyyyyyyo:                                            ");
    $display("\033[1;31m        `hhdhhyyyyhhhhhddddhyyyyyo++/:\033[1;33m--------\033[1;31m:odmyhmhhyyyyhy                                            ");
    $display("\033[1;31m        -dyyhhyyyyyyhdhyhhddhhyyyyyhhhs+/::\033[1;33m-\033[1;31m:ohdmhdhhhdmdhdmy:                                           ");
    $display("\033[1;31m         hhdhyyyyyyyyyddyyyyhdddhhyyyyyhhhyyhdhdyyhyys+ossyhssy:-`                                                           ");
    $display("\033[1;31m         `Ndyyyyyyyyyyymdyyyyyyyhddddhhhyhhhhhhhhy+/:\033[1;33m-------::/+o++++-`                                            ");
    $display("\033[1;31m          dyyyyyyyyyyyyhNyydyyyyyyyyyyhhhhyyhhy+/\033[1;33m------------------:/ooo:`                                         ");
    $display("\033[1;31m         :myyyyyyyyyyyyyNyhmhhhyyyyyhdhyyyhho/\033[1;33m-------------------------:+o/`                                       ");
    $display("\033[1;31m        /dyyyyyyyyyyyyyyddmmhyyyyyyhhyyyhh+:\033[1;33m-----------------------------:+s-                                      ");
    $display("\033[1;31m      +dyyyyyyyyyyyyyyydmyyyyyyyyyyyyyds:\033[1;33m---------------------------------:s+                                      ");
    $display("\033[1;31m      -ddhhyyyyyyyyyyyyyddyyyyyyyyyyyhd+\033[1;33m------------------------------------:oo              `-++o+:.`             ");
    $display("\033[1;31m       `/dhshdhyyyyyyyyyhdyyyyyyyyyydh:\033[1;33m---------------------------------------s/            -o/://:/+s             ");
    $display("\033[1;31m         os-:/oyhhhhyyyydhyyyyyyyyyds:\033[1;33m----------------------------------------:h:--.`      `y:------+os            ");
    $display("\033[1;33m         h+-----\033[1;31m:/+oosshdyyyyyyyyhds\033[1;33m-------------------------------------------+h//o+s+-.` :o-------s/y  ");
    $display("\033[1;33m         m:------------\033[1;31mdyyyyyyyyymo\033[1;33m--------------------------------------------oh----:://++oo------:s/d  ");
    $display("\033[1;33m        `N/-----------+\033[1;31mmyyyyyyyydo\033[1;33m---------------------------------------------sy---------:/s------+o/d  ");
    $display("\033[1;33m        .m-----------:d\033[1;31mhhyyyyyyd+\033[1;33m----------------------------------------------y+-----------+:-----oo/h  ");
    $display("\033[1;33m        +s-----------+N\033[1;31mhmyyyyhd/\033[1;33m----------------------------------------------:h:-----------::-----+o/m  ");
    $display("\033[1;33m        h/----------:d/\033[1;31mmmhyyhh:\033[1;33m-----------------------------------------------oo-------------------+o/h  ");
    $display("\033[1;33m       `y-----------so /\033[1;31mNhydh:\033[1;33m-----------------------------------------------/h:-------------------:soo  ");
    $display("\033[1;33m    `.:+o:---------+h   \033[1;31mmddhhh/:\033[1;33m---------------:/osssssoo+/::---------------+d+//++///::+++//::::::/y+`  ");
    $display("\033[1;33m   -s+/::/--------+d.   \033[1;31mohso+/+y/:\033[1;33m-----------:yo+/:-----:/oooo/:----------:+s//::-.....--:://////+/:`    ");
    $display("\033[1;33m   s/------------/y`           `/oo:--------:y/-------------:/oo+:------:/s:                                                 ");
    $display("\033[1;33m   o+:--------::++`              `:so/:-----s+-----------------:oy+:--:+s/``````                                             ");
    $display("\033[1;33m    :+o++///+oo/.                   .+o+::--os-------------------:oy+oo:`/o+++++o-                                           ");
    $display("\033[1;33m       .---.`                          -+oo/:yo:-------------------:oy-:h/:---:+oyo                                          ");
    $display("\033[1;33m                                          `:+omy/---------------------+h:----:y+//so                                         ");
    $display("\033[1;33m                                              `-ys:-------------------+s-----+s///om                                         ");
    $display("\033[1;33m                                                 -os+::---------------/y-----ho///om                                         ");
    $display("\033[1;33m                                                    -+oo//:-----------:h-----h+///+d                                         ");
    $display("\033[1;33m                                                       `-oyy+:---------s:----s/////y                                         ");
    $display("\033[1;33m                                                           `-/o+::-----:+----oo///+s                                         ");
    $display("\033[1;33m                                                               ./+o+::-------:y///s:                                         ");
    $display("\033[1;33m                                                                   ./+oo/-----oo/+h                                          ");
    $display("\033[1;33m                                                                       `://++++syo`                                          ");
    $display("\033[1;0m"); 
    repeat(5) @(negedge clk);
    $finish;
end endtask

endmodule*/
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Fall
//   Lab05 Exercise		: Template Matching with Image Processing
//   Author     		: Bang-Yuan Xiao (xuan95732@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//   Release version : V1.0 (Release Date: 2024-08)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL
    `define CYCLE_TIME 14.0
`endif
`ifdef GATE
    `define CYCLE_TIME 14.0
`endif
`ifdef POST
    `define CYCLE_TIME 14.0
`endif

`define PATNUM      100
`define SETNUM      8
`define SEED        86
`define VALUE_LIMIT 256

module PATTERN
`protected
=HZ6C,&WYPZ^MX#@<7E7ESG3[0-GYX:H.H-9[A;B4I>aYC4gUNE^,)b\>A09aOZX
<@7-bcHb=6SIPC]G^eV@Nde=Xa-Gd>Ob6IgP74,E9RYJ&C<N=E]/.(KCOH[M@\_J
;FPNY,aLG<B-NT1cK\38Af],]9bWeLa\7,>2Kc2Q5-CP\+fQ/BFVZc#-/S0^Q?9I
F+c0UHYR#beT>5.][c_g)&P5?)2U6OTASXXHBe?g^JLRgRZ30JfA(WN)C1B,d[?M
AWSGYHaW]&I216D.V)YC9fI]F+6[&3L&XV1N?XH(8U9b/=HHIa];4/V<A>5>:FB#
J[Z,+_XI(+V]-<5Ocg^U2=DGN2^0^C2eLZXBb?JTV/GKQDdEf8;f]:WIG<H._CW6
c)<(,-SB)QAC?<YGfYe#]HP/79K7S_)c;?Z@b;+Fe3S^UNb4/11,d5#3HEC@9OOd
D3N=9EN9g5C41NSfXTA.eV=YBKG=H_?1A8:1B5=G2&c<+^#W6g.RGE8eWVUGF#K?
fe>GbP1G#/UaN;FNW##JTIC_>AU=\MDg9>YI]L;O/\@AedIUC6+5\(\gE=OcYQKI
VJFBgdRI]KR3OB-H,>@BKPBZ-)ZJc4O03=RFEO8Uf1>4Xf&NE::<;P8YM43fgDWN
@.Y-E?<2+Y(G>AWf5-cIa66:-#][bX+=Jb(@N3)#WDRK2/NaUR)R0Sd];Z7<.E9Q
CU8@7-acG,,SMM\@VBFV>E74DQS4a3EJWX9HTIX#CNaRc/N5AS0/\&X:)Ib;4/^.
6<F\18g07<CSQC;>;,fLa3FM=ZJ1J,##B5=K-2.dQZ@:.<O5EVA=U5eB;<f:GH=@
Ge&8T]B5]a2bYUCO::.)OdSL/)5D(?W9,)OF0N@^g^cM3AV0)fUcdS-FS,/Ng#)K
5O-Bc\Mf5K#/?JSR2\<Hg[2#>aSI&]W7BUF19UDJgP-LP=OK][df7VE:)O@@UD.>
CA0bMR7aH&7(M33<D/TN_.:0MU2G3F8_U<.3;P6e,LQ=TQLR,&d)F#PP_E(,PMd,
W6(f&=<6NOK1PCdFYJ/(^W45L@6_1g3@QaOHJB:IB=-f?1I:5>VH-JI(P8BF]K.E
4gTe#05[.UDJ_Q/f9I@\g&@Ba8Tb.VL:2338fF(V5\&Y<EJ8\G0.dg_UWQT1ZQD7
X]dPT6dM[8+[M0U5<SGHR38RW>BN7^;I&)d1:VSYM;HL=d4Nf_[18P.Y0V6OLb&H
>2O>RQG\H.0\W8.e>39\6adYg=D^<J)RP0ZS+II_/S:<XJXFB>(?=2-R5KR2P9/R
QcZ\b5dcN[-^JgMB9(P,&3ZBeI\GLJdV&O:/:;^N8T2]8\2NV[?BM[@&8Af5TMZ7
?,5[E0IJY5&:2a5/GV=#=//,cHO53eVT1@[2.&gX@YOHL6I)QCd;[X-WRN)F+<Ld
8+:@\U/N^g;M.R&BT1I^<Eb+?1729e@\YR\QQ2D_15ZR_XNX4EW7_0K2f,1C^W62
8cR=@AG7(QEeJXU#_g.5(\SfB6^5(+6.5QH?_;\AO<ECMJPdLWVHO4X57A[e;I,C
Y.;X7VS>3HK&FKTM]A[,O,0\Ya1IYHdb3e#6J-@9<:,1c[P/de1eYCbR1?:Y442T
(-V/_F3.GD=XTW8aA/\F4J@_+\8EET+H)-Ob08Y=aZaV@ID9SbU/LXH8f:4WW1);
fC(<b28aXeOGGDKcXLG?Z[P7MEN>HAABT_/,X-^(FQ4D@I+3MNQcEMBKF;,P#b\R
2H^6(E]M=6>Yf-&^<;RT#;e)dc^-W(\Ad85-Gb^4ACK0/1G+RI.@?XBaI+<X&(H,
gC7-)8Yf_3H@a(9:QYSY\#D0#A-4W_cZ@Sd9I7E9a9,IUSI7;.Y8LDG=YI,O.=XY
Kg(7b78:\GdQ6W6PSc67gbWddK7QJgI-b5/BM5-<QRR1?T34>aWa>378Y+H=e6bY
IdV8R0JWIY,a;_GNT&\)VR\SF]Y;RDH87:GM>d/0_VFO7cW)/]1/,]-95/&#;P2Q
YFd<=VV&5D\M21feRb@JK+MZ_VJ=L]^F:7eGV^&2]g/_>NR2^[-cFf2W#BN.HVD2
^RVWRPHa,ZT&R,ASUNE#?_0M4V\XT:,+,Fg:L/S[cQ^>_gSf-gM+L0gVS.PU#TR8
,;CZOD?Vg:#^J9g7<[V.([=Bc)fXcCR:3U,c/7@HeIdN[cd]K4:POP:,\5M9]C4e
J1ML3b?NJ[Ge4^NN&4G?_d,fP5aAPXaT\a1H5.fLNHOB4Sf#B6c2b:?;cbf]WDC:
LK61XU3g?BLDU;?5L,fE5RRGIXLCBSG[9N14>d)26>dbH4RPbU,J],6/fO0F.aBP
E6UUT2d#<LN.V?UeeUR=a<5:-5)-CD0K?&:_^=RV5@]3ac>W?feE,XSCGggL+Z]4
De\GTRI2(@,8ZAfOAO-I6f8>Z3IZ@755?d^2Q@B0beaY>f7;]?A@f7H8?QATA5W?
_I\eM5\S^9FaWa@E(PP>P:+OM7dVPMSZL&J@CO3]XYR7XCCD5S3+6f86L4WdcFE\
0fc7::DV-bU^QDO65e-9A]=Fg_CS))8dY+AY62Ia\=;#BZT=_H@S;9LO&=SabE5C
#WDI^;=.JTQdW:.@/?VaK&0-M[]VgYJARN9bJE@.PW2eVU-Be:;&aF_NdCg1:c.0
,G,>#FE5I#1d8,5>;WVCfL#?9eBZ&CI;9[d?-#65Rb2M\aV)A/V#/8\a(4X=91G1
CJbgPJI_@#(RaF4ZK-]4VX/DdF^Y\6f[Cbg^dF4U1PP74.NHO?G<GX,c;B3_=5R6
&ZQL-bD4Hb+L3[F)e6=X^D?a.M\QdEP[Tg?>@]d-FM^WX+23#TT#?7M-N+TO3^.Q
>53&3U=egX/+4fW[D8K0+9L7?+4We./?-^H[L2Kb&0?ZFG2A/NUZS8&ZD5(#>JWV
d/a)3G@)6W=XW?&QF1f@:6LXC3W([>;YW,/G9dTWV;PPO9]YbIZD5^@/NW7f&>e1
J-_5#CJ>>C5\Lg3b==CUS+2c_Fe=:Q^R+3bE.Y;f?f8U#F85.Hb20:-G./efMG;3
7#8YBN=UBS8LgS@6.<577Q<PP.R[PdRC9&\3T^D9UQ4/8PN(0G/g=:d20YWaS+TN
<N,f^]F,.O6O1dMA?g-gGV)fI0P2<2];L;FF6P#;g18be])bgR3c@DB\3ZZ+981F
8H8]QG,NL[WL?N1&M07:EeP?F&Vb+/g>E=]ND:?;a<?SJGMB+X\-PO0R\B9F,+TM
a#BPT?S7Y1fFX#7\W=GU:P0^FJU:WGN(D:\#_8#8Ze?W;OY58/A4ZM=1>g.AD6(/
@D7HT=^2Q>Q\8=>7SN=_NTcF)8bFd#eNE^2(BB8#/dOObMD)=YbQ_NgV8]g)c:-L
\K0974(UVX#+NCW#W:-FG)5PVHS#)NW880/MU@6I;9WaNg<=#]:4AXb9B-?e7aBR
MZM-eV^TEgXFD8-#3g#?8M&;W6ZC5O>4E^XO\;ZBbaH&JPe5/,T]RLHc&UMO^Vg^
>cT=2,fB[dfca\3DA_&Z\Ga8JbIVgb/SY@)OAD5d;=abd:L,Ee<E2V[?_)C05G^0
&@gIOHTdc3PbCXRN>3?AA@TE&CfK+ee#G=]LE2)gLHRc&&2>EEW>,.Q6aBB_.I>_
3K_aUb];CXN[dg[d-UNDFW(O1?06_M80PU&;()\KefZ(09@C,FL;16Da1/f2,<:T
CAVWF7QS:LRd=_e6gC471B<C2([/b_ZX:)ZG5SeJCLE_]R1+2_.d.N=1Y&/LK@EM
.<gfQf@@)KTM\ZfQ+0g.ODCL,:8P^d0<X#D2[4A<TU;D-ISI-LIJN9IWUfV&S@[>
LFc+3GMa^aS6AbEY-fgc64YM8Zd&>I3#_2UIN&L6?#B53fMRC1O2fXGV<Z0N[C4D
>U&^Y\Tg?T3\]@MIc0@FEB]^GBe_;M#.?BIB-DNHR+Y:c:DPKd9WSF]aL-[&;UHQ
,g]-X<;]_6B(c)?X,;/W(4K)?VSCYPcNYIf+8+,+aMXXc9d/[+W=K8\?2B9?JD[(
Q\/QgL?1Y<I2SeUgC+b27GQP1MD6ObP\R:IIBMS(>D=O4V_&;XN@Vf)U+9N9;a^(
FKY8a?6^6=,S@-68ZdV3/,NE?FZIV50K(#U=0OdBR2d4fFN;YG2a;=;.XFPWa+BQ
=08:?H_9T6UGT,?[F-@V9M74JI=b@dO-[:?31Lg#JO4S)[CUg>7T;gY&e]>?Y::K
fU;b?+<<R^O7LFL,O7EVQ9,6IGQRDJYe59ZQ;J]I?HdaOYG@TIY0Q_[CVVC]XJ@(
AbO1S]F,8OJ2=\E[PR];Z4a^b-UR4P-UD&<TAB=X,\?_^9:>/:.NTM#GgYA(\Bg:
J=3I<XGD)\KdV1V.NJ2IN/Hc;MCY@R.)(I,?WVU,EaRY^fd#JH-BW6^ccL]0Df>8
6DB9L:5>#8<,_V_5?1Mgb\PE-b\fDKI5I)dN0^YK9R\fX6G-3T(7SH=g\HMXSb=Y
HY3KRW)Cg\d#E5B.ca.aXD#601R\M87^TFc\P,ABS,.LEe6..KKQG-<;MLc_eDAB
B7?&#K4De5)]cEaFP-PWU-C;)1C/S#2,5/0\c<2W-/=CH:IRUe=dGC+Q4.:5Xf38
aD<2?R]Yf>E6QAPWY#VfaQ#5-)ESX+-fCJO96g]2d4_Q?YXDbMIX/)+25BX.Q#Qd
I4fHDU;[>,&aM\KPeFg>d,Q,8=@5g50CA.3YGSE@<]fQ0LaBd6?-J\ETHeQ]R8F&
N0Y2f/Z3+K(E8Q^T(g)R(QY3+.QEH,A]VC]Re^2=62@^:3#b89L.O1=3Ic>F1(/0
57ddK?X24Jb;_Z:YL_GWW6^/&3Q)8A5Y>RfCbTXA?<9[#QVVR\\I<\cGN,PWCN<e
gBQDP?D-VS9DJP&VVU&cE8>:0C84@a,OFJ6SBG#&\gJW/1&=gL=[79UN<2BMP.GG
cF:15K#1?/W14(Ta[T.AQB2gBJV/TP;<37+_:JO7EP^?6C3:fPW,&=/QPePFEY0W
^U)\K9J?a-I/Y+/Z>MH&C3bOfg2)\I--A:P4c##Ig2H_M@+O<Cb1>@:GZ&4Q?JB=
5#g?R4N#I7BfH/@]9efbM.SXAD0UW_aedSODdKR24OfP.DS)ONN>4c);?1C5K:T7
8E7QC3g3f&8dVS.SFMRJD3^7\E+?=<A_4bO/=Y[Z&XX0OU?4SFe#/&0Wa36X8Q-\
+Tdf@PSJ&LCSEaN83#>:THd2J_A84N.aF@>cfFb+F&A7>VF(KK5>4;G@MH&UU]VT
H=Qe>7FFK.2P2PcY2Id9C3U>FTcHT,PS?b:\8K<.(eW]#<WZD&_I1]U@IPCP+Oc_
c&,--_HZ8QD0f0ASgR8Q?c0_>N-9egKNSQ+.(HCRZON3F4cVM6ae<CLb#?g?A-M7
bBEeg2=2V@U^Z:W<@5&C?MK@+f[>V-MC\M#<<:H0:W.M>:)@5W-6H_g2@50UcP+0
YR8a1->a2_N;f8V\]4CZ.A_&aKE4e@30_RK)8A+3)O^7<VI(G?SAaFQ[A&S;=H/V
F-PE0I2.>HG9AO,>PKa>PIO2c^S:ZAAf=^:a4PBNTIR2(/_-0O+5OH:U(K7JZ@D>
f8Afdc/9N93G^VU3Kg.R_4]GdQ+4A>&CE;7S7,eN;H=&=+@WX]J&UKAEE02A_?LE
bQ>]/-9:b3f51XQ[MV(^-60VfCFd-ObGWNJ&VG;05RgXQ1S^+LSL^f&-7+TS7[GI
;N](NZ=V@VWT\f^HIKG7,;UIGY7\G^C3MPbCS&7YFfT@eHf2FXH/85PbQdeU<CDG
bOcZc/B=ffG:A_gPUC.\Y&XX9e<\+&YJa\_g879KQBb&cH\YJ=(]_Ma\NcV:b7=-
46\.;6S,55OeT8;TF8_Lg3&VKI=LIWQ+>QQQJ1O@f5/+<BEG_Kc#U98[R?^6g/f)
Z+ULCZ8@0a#.Q?>R(S[1QKU#e&AaA_MB1KKQaVUSQ.(;@5TB6YQW3/+\+f:I+3a4
a^7?M@5bdA=+9ED4[NW?A3&daVc#8?(E#a/S[/=(F<&_f_aAQ5V\](?CY\a+CH0:
(L@,E)1NJgNE_3#4WFfF)?YN/8\SX]G72KTD>>^>\I]^VZc993ULd(4E3UH-Q\A;
^;U.&[YfKPRaRP2#eGN@OPR>W@70Z_W@1X_KFW+a@\-5,#gX4ILUB]X0NCae<f.D
HN2,WS42I./W9\QXRG0E;[db^N(Z3?#T85GLcXcce\0J_6aM8P#0#CaaR3b[#2W>
S<eQM+1<>>[12H\L3d411.^0N_6.^^^-\O>7Mf/+Kf^<S7AU+b@@0Rc;X@<d&.^e
-O<:2g9Z,NN_@]F(EU\?GBR5fQ,=DZcRI-@9SR=X2H3>53_3:D7)ME1BVK<Q2<GC
QUf-NY[U98ffYF_5bg8,+>BX,OD\ECEQfbS9g(DR.\HU\_[<:L+:;)LR]-GE()_d
(0gdb\e-12WY7dO)7G1SV:6dM#a3[SZW2&dX+V/aL3G&4&^#Q[aXB;U]35GE-b^e
D4U;FYC+&bZ7B:#VaZO6JSgM?-KM0R/c^dMNc>FaN2QGcQWZAU1C2J6XR.M4G)GE
e8(fgRA]#N4#S.3fAG4&G8cOO3Y(NCFDCF3L#FPJM84XfF?4^#KMcTgfTK>&8L6Y
Vg@_MIRM,.7Xcf2?<fJ6<f#F/X8[6B))K=bVg7S<4PCc<((Hg4YBfe\:b3N,4bG_
-/[PO_:I/</0E(8UP(aGK?MB(eG><HRcd?W3<eU;/1+FUQ8egH/M/b.R3f#FY7FC
d+R^b3a9O9c>=,X4<UL.\6.W-PKF\aPe89:)CV8fZAL\]6(ERAIO27N5<2aFMRcF
g7\7_8DAWBc]?bMJ<M1a-NO1.bQ;)3:^Jcd<__@Ed8WeP3Q3=J0\5NcNT7Y)A#;(
+SNJJ^ZZ(U_b[#Zb0T7CG07AS@B7JS/)KN+8IN]LJ)LIV\#e5V&Hb7=)=53eFZWP
dPX01+IbA>Zfb.N&YGN_WZ5&95[&THGVY[==SRW(VF3S</b?;g(=X>AH4+U@0+<S
)b3I/I[4G7C.B&O#dW:]-Pe-c-Z[Q@QS7;DAKBbE9WOE<aAQJI7RPU]g4DM7O#ZI
W@O#Q=31M.<?J51939DEQW75b\480#&6KU,BP?VI(e<X#KW2]X)=Xg^f;5/A.8f3
,O-WF)5ZKY9K:>V+c^2XSTU/)DKEU#C=;)L)YLdS&0JZ+NO,DTY-.-2KNQ38e</>
#P5XVQ6=K\/E-W-M;#U-YgPW,JL(GAOef?BW-a6I7]>BKF0L@AFJREcB99dfdQ;7
,cZ)V?9bTJU>dO3Z,cd.0YNXEDge68XH7^]W6d\cJ0ECAdDEY--?Sf7NfQB24B\a
8>G.O+:@0>SMRW3(->aKA\6W3S?G/a9,e\Z#W2O-d@(Q^AG/(RR?_EQDCUPSI?B-
PYOfVHf&KV;(cHZTe]]1KP\^aDT:P8e/[0DD:PC0#DE^N,QN-=@d>-)C+2=FDa3@
bS]f/P(?9TQfA;9FEdg9#3\]F7(&M225_=#GTc8ZeQIHB#I1-80JH,(B)P]?)4CX
L:dN]Oe=&QZ-f=aQ4Q0+B-S6.4IJ3#:O#.gg?aA_7OXVMDY3O,VK<H[#3#G?C^=#
2-<[P[GgBefNcE?XKEb/UFP80c9LR(4W<ZYN<YHAUG?7BJ<(Y.bLP:>g1;#7P#(E
b/&C0@?_4E:7=?^YOB30XMA>PRN@]0\EcFdO0FMG(/^;GdAONYJ5(LGaEKbgS0:e
?E3Be^f<NdCXZ-DB-[2J;72BC4e<#_3_95-+.?@fI).f1@LS>141\F@9aWP?&S9]
)3:#.Fg1bC0=7gHB<C,0ZT0MG\V\_N=eNY(Y+2MdTI5JFaW#U2]=264#5&9<N+V?
:b@Z,6J;Fd])Q67D@S6b-OHeH;#DFCfF>JBV1;TWN0gf?(Rd7Y)>Z95/2@(H0KOF
HNPE0>I4(=6N1W[90QEX3=bXBQb<4d0abUf<TKZ\ZF=U>A9S.UK:gdgL,?3J@8L:
?CD]@DSgeKGGXbe77(J(P9446LEC&^CR/E?YGS2;Y5XYc(T:^a-gBOf.V1;8+_0?
+G57;MX]3[JPT6gEYQ&]WSJ[NX6MAFaUGb?XB7,5V9OPgO\XQB_BR5RTBJQ8/RPZ
.2ZO_N:[CY\_d0?Y#@T_W@g79AG)L(EF+?.<&SBa52ESC2>0I9)A_ITZSEdYU;gW
7MEOcUMZ7N?05QHOfI70e[#);L8J@5gb0eFR7&BXY[9WE#1(_YO1>03QY0gXJ&T/
/25RM8)H>cF,DAM?d3PU+##1D6K>aKY.dHSY9\FB2bBg;MH-deDYDGCUc?a^VX/D
P1b-Qd/(VDX)5YAfdb4fcb@00Q;F(9(fQ799:>+.X\X=0<<]8=-#OAT5PgWf?Y6^
3a93KOYW+>BXabJgI/Z+]8,fAYD+0=/bVFOf,+IK^=NR26QQ(;f3U=J7T&Cf>50D
gL#;GO=#-X[1\W03?F,IcK:N943S<1_O@X5Z7-=gbO>P.;-FG.7OHD5[&++/L;=O
&1UCQUS7McWQe[C043d7N62\adKg(<GKdAd1;(A8BYagf6GUXDEF_^MQJSI\..2)
0UEEVZC_,AFC6LD0/]RF1Ma[32aUY[F-S,7\0c#/-EWO(GF9H>b[K?R.,?JA[e+?
O?MT/[HTFCTD5K\1AbB:BR9LPOOWf3BJ]5XM@#J>,=4Of;_PNO&>+;+J=1Y<4]N9
G&WII(:OHd]E\2f7GV.DPf/S\PdYI2?bg:CFQcL+aANZKLU@a/=E??&N4@L[8+bC
4ab2SRO@c8SXe(D+Qb;D-5Ra6Gf3cO,P++9C0J2f3e;P>79CPgTC&&g;[O[25?+5
F8PPL)1I;-]I(EWJXb6?1\?D@_O7];gRS+2,>ecDY[-XDW=>KRT2FJ0?A48#Qg=G
M;G(]A85H5F=;Sf:5fZ8b9CUW.ceUK/S)B(/a=@WNMQD>R@Pb;)WB05.e5#^]DV<
@F3#B#/B_=f)^O_NXU4\G48)0]&e&8Q\K=M&fN7LdGO49[La:(#M#8KJGSM<WWZC
>M:LFeEa::FB@QZS)b;CO65^PeIf?H@IA\[#VH/C8-Yg(]&Z5Z0\YA]XD<DZgI&L
4M0S2Vb?Q@ea[5eEH\//=[CL04T)=O0fQOFR09D8#c-e](Q#)LMOf7<WLO]KJ>7L
\O0dL2<<D]>4\d]g9cg],.UICHBL6W^Ugd>5(c>dE,(BA<?P\D5-8Sfb)HF:^f)R
A(MSFBI6[GC;D=EUD399#W&?ENN+:JCISC]]CAN8.)SOD2M#,P?9#L?ROC2c7K&G
^>decQBbHaLK]SEY&:ES^g@dH;-_IFA8NNSN1>6;\?AV623&;OHQ?)63UA5aD-KU
aaV.7?JdQ_acd^3G@N99#;VHJU?ZWf@)Pdge]FY)HV@)0AU3Bda\@BT#Z]DgMI0/
@3e8REHU0W.SG1<2H+Z&A0I#U,RN7_RL@g#-(daA]J5DE?dO+_=c\f/#,YVYaJaf
3AbTZV14a,W=6;>.>Y@SV7V?8/bff&BWe,4#=R9[ME?26JY+9Z_N\(S.RIZ_b,L/
Q7:,<-5?B[&BabN#,<2-MA^VGUY3bZXEWBPaS,bb[GA7C:PXWe#K426RVg4S,59A
BJX^GHE,He0J9^P+eATK5..9]JM3gPXaX)AfO];<Cb4>1H=cB-]P^-MS:ES,;+==
B4[c:CSe^e.e6/f<^>#JGDW=3V_S\@RR2_Bb8@2QH\=#?1\ZVAb7+-D/.e_,_O(1
YB0RCM0AUSH3Pe)AJ/W5cE;Gge39X5^Y<S)5][AE1WOUD2ETWUWU/_6A)SC-<Ve8
KS#5_NPVSK9c4YAU:&]V22.dcTg=G+(<B@(1/CK3OF>Ka2Z@[Q=c3>LEbD;D)47Y
7f(d+OKVMT::OGOL;I?K&c2Y0b^R3Z\2^f..&=7(7F8e]9R_9/\_Q2QGVaaQ_ZT>
Ve\X(>C0fFVM&[6:e@W7GNb?QTW4>eC79a&QLWcK@HdKJ+]#8@N>&[#^X3b5TCZa
2cM.We>(,Y)YF1))XHDEH(U+63Q;4gXB-\cPM@QH.V-JNZ[ZL0]TXb73+399\/)^
7.c2Z1?cZ,\?9L_BMd4Q]fKf?-O5\D\9ZDX.IC-E+J5T#6Q(VA=028[8ME9JOJ(5
LFR3>(V89GQ/VaYCJ)&Hb,7[@X5RaT&:Ca(<+8T^2RGFC6L.bHF3)BIB,:f#9FG_
B5QL/=]9ZY.K83S8.I+N7dd<53F=JX&;IDT-SG97G6,J.?W,8;2DLGS,R#SJ(EFN
AKWW+(>c6/PCZJB,VN1/+3&3aL4(F;1.1@B;V_<@KV(dg_0T411Y@ZOB15O]A]D7
/HcD<.C/L+b^>_/].1#9?0PV4#=S2;;e+5OSP/2Ob-:L(B_NcBJ]aHZ5B9fgN:3F
4/+dG#^R5#GBG0Y>S3)>K9OM#6b?RUEED?>ceU5M.GX:DaSTHT(dD6?YZT_/1&7@
@##_?88+KIa):]>R;1f-Cg>7)2bALN9J)C=9H9)^;(NYZ=dP?ZMOIUdEb9;0Re(_
4]1@=Y.I:a6>?AaB^S\,ZD#WJcZD=aS;X#fPWa+RS75^]6\\gHMG[WB1b?:F&_A\
gfX8JH<#IQ?:9-NL8K<]Rcb;2X@MfL(7(R8ZI.)S(WEg:XOJVc0f;O0c]M4IGT)Y
:/g.Nd]F#V=a0U5SON(4)T-W+,JXe#]-aLBaYCB<_NgHC#MT@+B<(Of7X?fG2;gO
NWg:g#R?f=9BE9E]G/OGd6H17-D#2U5WeZ[]+fF_GLL9WB1c=+bGeZOXR]S69&H)
D6^)S2V8(+XHC#=LgE)(JWXQR721b=aFSJV_:Qb]ZSK06()_=TIAe@#L9SaK^Fb#
9dAfDM5_6?-HL==]Veb4RN0a0^\ZVY/ID6+BSV4.C/;(XYKED#c,<N;\Ee+?LY@L
ND0H,5<R=UL)BH04<;22-(PG&&M327/2L;g/d)Xf.MKVRM#Zd]9O:5Z4D32QTM1V
BJefDIKB\2J_D+.^-P^XNd4B,KF0QfbBDG6FWC\9VW)[RSI2_4ELU/:/-5Q7BI<Q
<GS9.@(B41QR+3]Q2?[<:OBfTRPXf(6WXE<1PNLV&MDbe?F0HY_E0W[JBc.BAZE0
d9X3L?E5:H6.8)O2C7-A(;_9,OA>KD93H[2cD4BFac1[e_?WIGe62J4BI+-JSWIK
6e10JH8dUZb24R.?SL2Y9191<d^ML-Z6YE9SRG-E[36DZ1:4aIa&C/dZe)]\.cP_
^KXLg;K)SQ>b=Q>[f9<[V:_PG6fWOgCS8RSGO&A9S2;(AW28B\(9:^\K7QX/gGF)
g;P730EBFN7XK&3Z2CfM00GX=cH5CF[dbeONbYFU24:e+F^=8edF]01\?f+I;K;-
1B;I.d#NF[+W1NdE1-TgE(<QFPgPb,AX9fWI8d<L#98Mb(&F@B28_Z5_NX@@@PAS
abB#600ba:BT9+)?XIA;:72+_]dE9:ATSHRbV[+d,G83[@L5Kf5_OfV=+T@XRI<K
bB2B.6+a3BLbWd[Q)RTbX+AYKSY3cL\FPHR7>OL)JS.?:bQBRKeg(#T[D<e6^-^V
A2\fd);B18XgU-^RMaV5(M6E1c8(V8>D^3<#1ZDfNV9cQSE_/3^54INV,FK^:U1#
/CcNKB3L7I2@.>::BQ#dW^D2P:=E:56QC@1+:a#2>I_fL2-d@?/L[9=\4RN3)f=Z
LSOc8_eWYKc_H)MDgU3HOAKD=N._XSc)1R,TX];W2fb+TP0aU4+=)5]3XZRC?)R9
A1fa8(1G3G9?4<cOdA:Y3LLOQ7O+K,^NE(4NQ>gOPdY1T,S3+b2OU)[33UMJ7f-<
e)Te;QI,[X&YBL@O:V&,>UI^8-]#]2\65<0X;2A-^CQUQfDI)c3;fH3Y3@7P02T&
/6dYG2NZE1_DJ),^^/H2W0(IQFVV0)aF3&QKcOSQ3A:FH@2QTb^G<4Jc/->Z:H5c
0a/<]2VbJcL(.KG+b51A_\][e)MSHcdN)H<0[U//J^\[C/P99TJ5IeB@Bd2^Se2_
0H)/E-=D7R>EMMbCKf&<[B;3Z9@.42@J;^ECKb=PC;WQYIU=,?=dd844:#;]fW;8
e9U5eZEWE6)04M:>D-I19<^K95L70.>5b>e9PbJQQ2b1_D-@9@;3X/OdB#>?D<SG
&KRZ&2;Cf?fR>];3#AHCYA?;1XPRg7P[XYFJEJZT[4(NL.acd]d3.;S<G\5_YL?N
;/a+1F_/IB<)&\6=RHJBN<OBf07GI1cEFa1f1VIf;T[<Z=F2Q<K(+2+9S:+gXPJA
?-&-YOU;RUb8]fT)(1g(McQ=bY/Wc>HS9D1c]OcBDC=LG6=>@Ec6f9HHe(352,_E
>/Z28AUJED#I7ZQC0:ZNB]CD\Kc:N;\Q7@#YOSg[+F9QECV0_4]MJJO6,L6UbgIC
a];6X,(f/X][W94P<a+\1PK-(T>;TFG,27GV];4d&eX38E^#1b9:[T=X3gJ1U5F2
(>ZAf_IU]RLO^0]\TN)3+=Z0Q7:Q8WdO-/:=LC^B3NTHVSD.PYG<#SgS5?YXDE+W
gc^MS[[^<.G+=8AFg8L(I-LeQeI/[b2]2_4C:U:_Sg,+&;]aeCP^eI58X>VH1c6D
Pc#8O\_3=a3AQ=G9PgCR&Z(>6b,C?7?P(,QGM8fcVOX.5/=e)d>ad@7W]\TcQd9F
eH2TGdL3B)]\dW1L:XG#@44):4IcU+B7=\bKDJ1R\R7WeEUg79TJ6CBY5^LLcYR5
4:M5cYb:3DQ@&5b;+EYUS,gS@7&?[N,BXDHWP+fY1L[/ae:1Y9CGJJ/Qa,_#c7S>
/ab_MUE4Jg#cQM>V+8afP:W?1Ie)&;ab&9gM<c\&FXbUVUHQ^O9b_;I&B/R]eL<?
,_=eEB;GJ\8a)R?WA\]#JR\EE,,>e1aHPRBW)+D0N1#/L(.37MG[R]H[-#T1R,/a
>\\J?I_4ISJJ4&27N3_eF=QZR&[Z]OA.D91>_BCDX(NAWE\5#2g8,@>-A;eOV1M^
2@-E);[=KA(=:=(1A0Y>0<GZ#QR>ZDL#DB:XE2QEe+=DIR:b)<BQIOFOg8KfQcaf
g]6JSbN>43)gDcZ5VG@a2)Bcg-J1Qe;G:W:;GALCQ[gN&[eX)b77AJ/2F2>:<2aa
3)G#;3Z,&ZaA4gV;RIPKL=<52:?;Oc=R>GC&^3c[,G\W\@3PdW+#)cfW9F,<R_F@
+[,>Z<]I>gGYY9)@:ZUFS&-69FL:J_CL@E>FRLOgF>IBTeUJ.4+D<Y=B8-VBXGb6
@g^PLYJ=M>D79(T:#We1CF+8#]0.#Sc5:IDTbEfO,=WU6gf9(-5@#>BP0QKN)>:g
EAF50VWDe/5F_=B/cZ/IfYXA:)DN58-A6J+dX^c&-X[-;QJ4AKH[>7A=Y(=8TN=7
;MMS[RNH=#WFO8\ELG\_fW)Z:.S^]3PII)#EDA:?Y+FE8c:2\Z7[@J&Q+;Qe_RRV
Uee8N8_D3+bOF)]-PA^QcK:E<NH=\W:T(5]59SQ,0+DSKV#HMg_Y,;a0S+@AX7F(
IXV[-)\PI=[DZBHOSA2=OMW2_=#eDIZ-08>7ccCe6W7LU?=TU^A,Fc([<))/EW5\
Wb:@F:,6E,C8fR1UX@d;BEN>3^B.dfG.5-,)S(Na(&P#aW,NSB&E<\a#BRO1JYGF
[XLZa#4(THAJ3J:(gQQ9PaR&+D_Zd<eaDeCY9E_R2YeJe1Q7^^B/#QM/b/b?I2(,
.:.O75Y;C?RNAJCde3.M0P@T#7?@TZ?3).\#WX8cJH8;C5BZ&I1@Ld/(.T?P?KW?
>Md?_(DNS2g_6#[YXb:A3A1Cg;V>cAL@(@9M<bIcE5+W(M=0K,&5/-:d8._(93H4
N?CcTf2]RA.G96N8FMNBc4/44YM0LOMLYDgb0.f1ee:0M]5HcKTE3-IHA,7?[Hg\
6HDX>GP/Y_c>KHAcM#=8SDRYg)B5Y<O5JN/?#,PU?6,^B6>;d@IY)Tc&\YJ21>;N
HY+-aHDc4A_(,b+Z,]ZO#5eIW\M7)L[1d2I-UL<ZR@dd_VG#XV4#8&ZcSZg3PE@X
Ng0SMASgVTYf.@6)L&6\g9?<,.Nbe+UX+9L&RUH:SRG+XY]U[EgMbL-1B0Z[bBTS
;7\)EUB]IYXe0&J=,O]d8(T1H9&EG[LDda?dD@e4)C8_?dL9JO^bVG7#3S7]g5SO
fIa/Q&A;c-.+\b?S2f[gYZL[C_1;WK#\DW^C?eW87,X8CBNE97?0F&J0A1,5_>15
;=^e=M_.f)9\L=;b[^HB64aG<6C\>[f\?F#[2TdVIBf_R-/\6V[8JV_MTRI(V5eP
C:TKVTC^bDJ10E04F?cTL+5,14XHZ2_VIE43edH;<,6e\9T[3YWP:ERPd+\39#Lg
M+^IPde5&,+cPF56:HEAD651X&Vf<YYU+g86GTeE4)X\OXK54C=QQ[a,HJPJR/P#
;X[]5a81RI8K5IQT2U&7SZE[\.6P/AE^@[SSd246_\(._RQUSH38]L4ZHC-->FW^
=\/9;O9[Ofd(L.)f>3U;K7-I2P+HXa1-\L93-MYG_D-7_AL8PKG8GJ7I;>dD=3V2
R87CJ<VS(7I24@:U]C=<8EHdI=E/KDY95d#8J,^FeW0aVXL(U7I1/GfXP,.973WM
]PH.32a2Y0\d,U;+R6+[S-gb8Lg4:93W4BRX^IGAE@O8&X^^<3IP28UJL(OK^#T0
R;@T.RZYTMB?4)5)-@KDXZe-a#H.aNT5L>8:BdTER@]62]3\K7#.e&VMgKYW1U\Z
a8,9;Gcbd9]=HLG2b<ZD,Y[bJ(3-(OFA\JP+;#B@3TL9+Q#fUeERe&A;aDG;H2T^
)>JTcLX9;@YESHGUJ0Rd3)7fW/f^^&\bbA:EdPD__7UOKJAH:T\BK9TWTWZd)-A<
F,/2-O1@/0EFU5?YY+OB>0KK]_]cH+eQC\L6:9-TPFHWJ^]9H5g_@G<S<N^UV/eU
Z>,85NNN;NZ(71SS:[=DfMH&0<KGF:A]dM^;PC<[=:UI-L3?&MYC9g;&-[-CCR<Q
\[X;L6+RON5L+NGGM^.[VM#P[I9eg+c)OAgIQHF&>Zd?Q(:&C)6AD_Xad7W9:VGV
aM93<WCS-HWAc;66gG+)/<5RUP_?.Y<J>1N7?5fPVPSG<VI3D&J.Eb9JUNb<Y/?)
LKMc&I_CbN\##<GMA[(/=dI#HL@dgcc+DN7.gJJCNHdBX@@SQV^I_b2E8&QL:0S+
d9Hd7#53gbR)^2bM#OW8&@1\V>g(3[CVU)1F.Y7F8B#XY5=O4X>TCdL)ePVa^__7
.U.,fRWKSZWG_:HIX]OKN&6bTV]O-gSKFF0B8XGf,A,dW<4^CIJOgI,VDd9(IOCd
;cZ+;E\[#=_Z=X,/Q\/>Kd<]VL??L<O#bg.DNgV\UQd;(=O?#FeP+EdKGDdc6()D
FgN&X9S?:^_C5P>S4#E\5O(bg)PQbPGM1U>f,]7GQUd30&S?<5;EZf:[F6SFSS#)
K+.<GM09eN,1?Gg8a#O=+4-(K+\Xa>\T.\R;UJM]9Eegf.1]LM3Sa>GY,GF(7=N\
ALALd&?8BMS;@C2.E9Pe&08;QfA_PRRIWCRH<3gMZA9D@HOKg)S_R,Ee486],H+f
H+a/=A_\3f>UEVcN@E++LK.VdFM,,V8V)eI[T#_N<Tb61HMU#(;)&+G@9_)V]+5I
M&V+?TAMaS9#LHK2eHUGG70aE#ZG9S9X.4I(L819L#9SfQ/)=aAVLT<^\_e\OY/Q
?OKPg4#,:2\WQ1d+P#=V1Y/>H726Rd-a&Cb+0QP.Jg+\@<A=1AKX[:Z1-gf_/S@@
g?BQg]KQF@L?XBDK7EUCg&/FZ4STC@b<KC6(F+1b<bLIOfb,+JK>0;K0&8J^.H)0
?WO5EY\gU0]6+&N^c+YfW_?X51<=(&:F=?Pc@T[BNO\GL9&(AO&<g.FQR;Z]RN)8
2gG.g,0VD.7[ZB#K;.9.79aLaE/c:=_Y;/+\@\C3N?L>P@.5MdO=X^75dIUg?4W7
L[Q17M3G0V/X_.K&2fd->d3B?5-:)CV<#\J40e-bgK2,[&_fP<0\OC6P:gA&>V3.
Z_563#PFI.#F53?8ZHe)K;=,EgV6]NIf#V]:AJ48aP8[gDY[J&g/8X2Icc>_D-PH
8SW)eS/QV[,/5XFXIC#Y2b(D^NgMaOSaF=.fOS2<\\RFeZM6E]:C],:;G\,[A&9]
\g:+>N-N2SBH.AK&:dZ3?6ca@8dVNYOVG#CfAC3?+M?88ZU_^fKOC&?9c05<[]MN
d4;(bQ1TSUSf#R5)PASGBe0.fGY\^W+:@KR2:b0fNRfbSH7OG,dKHeYcXWcZE7^(
gVSG3,]:\d2d86&)2PcXbPJ:ddCRAHS+P.WGXYT;YA1fXM6KR,b?Y/=19R2B]6L<
B#Ye<@,<UDM\#F-PX8,:1(3,Q#+5b2[ZR\1<dZR]Ve4?:gQ]:>#DC;G;cE/e.g/P
?eB@Ada=\2?14?@&-V7YR0cJ[AcNe36L&LIIHSPT],CC<ZJR.da;GRN^P\.<Yd_E
57A3EO97GM/#T#Z1J7Md+10e,Od62HOMIBY&B/AMNEgN[VZ<\(ZMD^6R:/USRCL/
-,X5^dT7fFa;Z0P[CeM>g353\VXA^JD590bA<?,Q((FWf><)SAI)_,AHCOcH9Hbe
2:L77):DWNKUP99-SA)>fOMPdLSH\BRFbe/Q0cEX\W41ce90^(C<ET3^-1bE/I19
&7\):XGDDD_(@BgDKF(]^-]Y[),F+@61@E<Ja:aPJ1WQ[::VWNB_S5@\2;_\)95I
X-W]?9OS#XC;)JDOENI6c59T>_.O7@B/LE[aXLUdQ+^JQ;RHD=Ha:.]V/A<N=OSc
,@e7bTN5;SgZYg-6IU.d6HCV=\C3EBQLCUgKS9C+fRKKb/5=W4@@;R>:Ug[e=ZDD
]8A.X/I;@8D+aWe2VfG(_NIX^8DLfR)cOJHD:N(a[eA,b@[(@WKBON@<8@_0+QM]
7O&cJ6TZ3W<;X3(0])HgUVfRcLdL>F)+[)ZaLFZY9RJ:gT\,E,+\PWBH^L\7:PA8
YF&_NZeX4WHHLfXeOCD:])1:QR:Ge2IC9aO=M7D.9K)0(W-9/TDF_X20cGM:eR2,
C9)J.O<STc)e&&G]6dC=J\AXBUW@P\\M-U;NY(BLgN#BbPGYA>G]V+3^?^UHd+#H
?,c0C9:.g&b2IH,>IIF@-9R0X<):&][4A#bJPI2V.RSS>:0JO@CX7-]?=Q4-#;-B
90cd>C&-Z8L0d\P2.I:]>,J\NYW_=:\:7/Z2X^A8^>H6<?cTUa8]N-XagMfeL/^P
OK:\c_02DIC.GI]E>C>X7JM3bN0=>[G@Jc@&8:C+X].LXc.?\DN0JLIU#,Y<4WRX
?WU>J[&LNf&H?FLE,c)MRG<5FT;-UZbP\M:X;HP==X)U/38f+JX0_^X.O[[7e&;f
AO:_MH/#S0CRNUHSCGM>AeB-QdI9SEI(cDVI/]Zbc:3FN[\Uf3IFAEce5?C>/&K\
.RN,((.H2+@IBS.:]^ON^Cd335bFF?6f7L#9.&XR/#V_:X\RU[JF1>M8)gX8LRD-
&G18X_1A8^-94(Ef:=Z03MEcD&3M30G,cc0:_)V=9/WY)0=?+P?cf_.5,;4>S:04
c=P.IM/+Z6<e[>L=N@>81P5O-?@#f[?BX78_?KU@b=G]1>:bHK,#eJAVOER,+SP)
)Va]83R+9(T;4<_(@+E1JV1gEF,CK7d-NX?&EGYP/UK(deCL(Z_fW?GC9N<UG7ME
&8)/J]4gVBF?,-5NAUE8ZMWR:23DN1^H-H]HIN7U_3K]L4_V1\5-28_FT9#>_@R2
_4T4-I.XbR<AFJKI=g)A.:,N3QY+5P/O<0>7?cZ6S#@&/9EZ+1.-fI@aBf+B=?dG
4CW48&CK_C49H6F-:+S/^fKZS^e_E_bEO0\D&gB:KN?+gFA^JSB=DC)4^=0WK0H-
4_S\UK]eUQ9K]F6@TNAB[IT2b4&N>9,QIA]A>8)&_?BO@IX=g4#UG+PPI+8]LUb9
(@H&YWP?5CR9ee_&_=5MbJ;)<:<c->(K=geN5VJTZ@OJ9H)1D^H)OPAX;)P..+a>
P/83(H63<+VM:CNbDS/c4)E+3gU\75@fS&GeKQ);/8<;57:d9<dUBL\c;H=;c>d:
O\cBXE?fd3&7dV+E&)ZQVU#R^gW:\X]L>=AY;@ggFe<WG)G7T3AgcK:;)YNG39KZ
4bY1B=gOAfaR)Te_VBV+V<CV;454W&;.Q7Y2C+CB-H@0NFA(I/VcLH=cLGY)Y1#V
^#[c+J/OMAR_-:K:/]bOJ\&&?abJJ@2#b<97,P#gYHJaB?bA&-:E_:M\O16(N2+8
W;XO\1d)FF__[.2fD3YE(ReRQ0+9UFC0J<\>gf<TA2MMcaf7Y?B1[FS[BTT5;17U
J?f77W^X5N9?<LV7eeGb,>S.]=d&11[/3>ES=R2b3;Q]B1299.C2II]RS@:A1a?M
&[\gZ7@9)&?=0K-XLDgM-@RDG)?O],\^feEN5QgRcVT.PfSVF#7<@47_@GRL>VVE
EAf<<R=/3J@@&)ZL)IGfA#>Qf&\<<7.4#ZcCSOCSGO>E;g1A=O&SW-D_Y[,a>_6D
e1RNQ4#DTC83+@dQ;5#Egda.NL_O[4+c:e9?7]//KbJJ:@E^P#If<@,L\P)99/Z0
dcb5^_0d6BCb4V8g.<LBMKY;2VC1Rg)@OQB2TfX>OITXS3MT3K,MUPDCRTd^S2cC
_&)Z=V8gQ\\/fI/:/-a&Rd?M0PHE0?&J4Q?Ve(bF/J8LB4SD(;4.c2>Q\>b4\[TZ
J/gU]GT)[6VH7POJ>b;D?J/CdJ=/(V2N/3W/=CBE-8gJ_Pbb&QR_cOTK.SNFDcIO
cCJd8=KP?N22e;4,G_U.EF,LFNSaH_HMHf)1/H_Ma#bHI^>UJ2?2>f-SRgV2ZE+L
QT8S2:W6IJ.1>EUG51NSOQU?\J_]KTI>F<TUPU]>dXd3fEB:d3>a#b),10ZIcZ3G
aDJa/eIW3DEPIM?S&FaAB&G_?\0KS^_OfLF1e=M7W0&;?Bg)\_X4S(g?E5ZY#P/F
0LRbdY+bL7P\,Q43O,gPJ],LU;,B^a(RRaX0=?e)TNCN;8aR:>U8ST=G:BQ.94E?
g5#V,]c4/G+AHC44[FXUZN8_VCdXM/&1Fg8H7@._3E56OK;2GccK8+X]I]11=CQT
5cY:CQg+YS#;CP,bZ/3N/15]cS9>bSUXDI5bd4&:YBQH34CeH5G[b9A8PK,W1A\\
bL4GCSc>T&H:=X0Q#gM21:S]eX:Jba6BI4^_?H-99?QFV8dC.)V//,a:D5V@EU/A
_VEV)PF3?b_1/?@E<[/J-A\^48AJ0/?0fE(g^]0gM?C&26Qb@:AfE</OZ7I^Y)CQ
9VZB\#Y-LHP.I[aXd<9(f8dM/Kd@8g]b[J>E(ZbSaVCd-[T)Ng4bGX+g:a_3>.LR
K12Q=a[WT1#N6T\S&NG9g)8766PP@D#/)0bPdVX6)/TS6edP0XQ)M=N5:BaTGVI?
SB=a<?24U&;EYag6ddE.;>ESQCY;7WdJ,(FO9TbL;(RFP1b#O,;Y1g0#N#IB9#T6
/a?W9e,Z.\WIc6J24K8PK^/3a<:IU]<F^eDE>#(&>G)H;?L^6\6+C-d,^L=\NDa;
+\6PfQ8DU+Y6&K.S(5,9K1A;MNHD][H8BE61BI>X-b,-cAOFE\;HPb;1Y7/g<<R2
(\U/3^a40;^4Y5aK</5WWKN/F;+I3;O=LWCF3g\COF[a_YZMQCc-P\8E78@>]/(7
ILL55TF[Gg<\40>8Bege^_M7R.7d<f.:e\9<6,4TW>#.Zb2HWd>5,K2>\GIe)-\I
MBXd-&IAffCMZQfX=/X6W@<f&C#@E2?WNA7P7a?45]M3.[9Kf&PP,?O6M23Jd@MC
,D>8dAJ4YaWZ/c5;Y7@W4#c\\PMJC\c?5/E0SIJE33cJD;)=;gILC(3]]:N<HAFf
cZc@GV:]bNZS,S@bXJVeFXW]9\F#X:L:656]W-VL4&-A1GVJ+SD/P?:EN^WWf[<5
L#aSd_@1aQ5@@WVRgP]1?CD@?QC\gg9_?B:@[S+R=:]WE\8KGC@4;@F@)U[W9]EQ
a+5eT1GD5\GL2a#5A)(]]XGVFFYXJ_/^@Q5@3PLXH:aBI#a-fPYS.bF0N2ZI6I8a
NU^T,ag[-O<SLF(ef:/_,-\X1/D/T;EYX4;g8B.g@RSKZCT>EA#)^M:RK9LUeIE\
K?:>-S7-]]gZMa/F7H:CACN5&?]O#7)BaC2Xe^VI)>b(CRE&bKJT>\5<]P4#[2-N
9e(=JAN,4,?1.dQaESLMX9JORe0[V,eD(;7+/48e\>5O&Q5cB:b^3?.C6RLO\1SC
S)XRX[=4L1PKPR(G?:Q>[O@SWAN,>?EPP@DW0L#)1?.7T\DIO+AB-FgWK-[#QRYJ
FNVQ<fR(9)DHd(N11N1^5VAb:32VM:&QT)\^#@1\ad>H:_9fM,N#b5F:L43,M&T<
.53-AU1<F?FWNdYgaV^;&SU2Q&>T<[Z@VD8-7H;;0[7:&:M><<Y@7&0/]CHX9U3Z
ORWK:GZdAH?H(Fd1K+9P:BV;S-==XK#ZQF,Q^bK;14FK8G/+93AQbDK0e/d:,R/3
\]&)NdY0,SJ]HJZ4WMRVf#LaONGO@gRPGW(>-b_DM18^K7;AO8cW\=CH]+.=&a[2
.GbX8NXB:5Q\H3R&X?QeJMfA2NL7.J>@1gE@_-D?O=LQ9<X<F/fNb1HTF5TM?Wd=
1F?<09ZPG84RA\EF9]\IM21Me^C(fTY;0W>c@+8FI0>(GX]f8#[V1DNAFH@.8.(V
=I@b]K5/_g0BA(^PUd9QHCBYKT&BI(:2LaOdGSTI>?[#cXG;0_ZE[+H3I?5)NO@F
=JF5HF4\W+8EIQ\MD>&+6Rf[<\eV9^Mea0EVK,3@GABVJ[V/_SG_c.RX:g?Me;3U
HAV81]f01455GKYM,&^a2QL3CV-ZCTc4d(59X)6RQ7V[L&=9],9Ze;4?L2@7f0ea
/B1HEOK1)\BD7/I7833;,W;5FD4d745[T-)\eIK3\8aH#=LaPLXYI;TW.9QZ>RAZ
,<Sb5_&1.ULK&LS^#KfYE4<<PT&F,:S9fMMb<;+MdZ)f?US^&+^_U(N]IV6Ve_Yd
[JU8FK7f(K+Z#Ze:54RUbDC:GXfKe5b^JY5FH+WZWa\fMAV7B6/.2+YMQLf7CAZ)
Z>Fb?;)fZ8/\(UWEG?\.MaN&dK?.)gaEDL#<GO2eWTg/ON@(U9&(^2\BPS-::;B6
c>#TBNL=,4BZ1].3EZTN26+&R7T8NFH9FJ#R@&5G>YgCaR(8H[S<U(X(:eZcNQMB
+1T]+TfNEff0_KGT<O?Z6[Q#J+PS23HD(YR0,I7]UU92M,&)A[)A;\bCg<JX?c)O
6?9a8^Vf=YcMW>Z9FedL1HOe6USbeEd5+A-:GcdP2P(H58Ea=RAAfJ.]a5a0.e7V
VBIJQT)=eFf(MKZgX^4e0C-&V6fWc@a[I?ZTb\VSFCDKF_LP(8gV,&FNV+;b_d@3
G(cYH^9QW[1#[:8T@#Cbg#.E=TR47QG^B1]Ig^;ZM)X5+b-9QH&TV+BdX]OZ&):a
5]X118;+;?:8I?A>Q_cUGC,Ycb.EO]ETb)d^03(fQYI,^RQfL,[a<RGC+FUX.>0V
^aXSQ[JNAWJJC&;EX5c]P\?gSe.^89/W19V/P2EX5e<?N5_?5+T#33.#a7O3cHeP
/I]B,<VGP9\YT_\VTQ^d>G^e,=.ZYWLY4,6T_b;-X0AV&XeOY#fT0Y8>ICI?KD/^
XIZ>2MX?Z+PEP+H?IXLPB4AgA.EgfQ[g@ePB@G.;YAE7;X6TX6D\,-g]VZZUK(;U
MO:D6HG_>W1H:XOTgb@ZJ24dfLE[H8Q^]:&I0AQ-WK_Pb-:-ZP3bTP-B5<//X\EW
459(\.YUg7Lc7aU,VVV.f6f+59/8Wb944;Tf;SG+K>6^/Uc7f@Y9F+U3<]0=?LG&
6FQ_N=QaE7#egVC0\24W?V+UdWXLfA;Rbd2(/CTO;()-]1bGYfOR@(1@Cc5Z=^TW
YRU:1^#K_1beZ/1aNELf+_?CgX#I(=@d7XYQI+E\A:ca)7Cf@:UgUE?14)c^WMEQ
Z^cSdH<F&XI?GH3U-/;VOM?FHXT&WYbK7[SBeZg?CR@0<b_2_La]#J)G,);1Q1:/
3Na_.]B<)6OLW9d6E8f\D9GDPfH)?4:WQX/B#C0aIY1YQ+J.^e5JUIc[AGRH>>G7
?QIV.:J^VN:dSE)<3\VcX0#(d;(B@6VD\E/Vb\bW21@2[eF-RgLC#0^=F-?K:&JC
<N)A,RI:MW)Sb>MTTKgZ61c:OQC3HS]P-V[C950Y.F69:AT/T^O=(@MJRY@Q0BRY
GKFf/DA9ZBaYW:>?M8L<;AG]gP^@2M/Y15ITW:,B40dg3U_ZI_SI&DW(:02UN\JW
15H#a@Z)>)Wa.KP[6C27I72W<,D;;&P;gQ4d2W)/^V)CUCCE/QQCd1UB_+_0T&dD
Q95=8FcO7,R8(H4BfIX4>G9?O1P8d>]<BWAfDD3f-ePW?3AN&1C1WGMd\GBM+81[
.e>OAI9V?=MJfY/?TMJC7V)]eGAfOJd,ULTbHbS053_#-&K0GXX=(AOEP4<PGDU4
C82^KR5W(H#C5KPGIV9UUA(?D&L-fCfEMWKeTT_ZHQYY/G)C\1NdIW+7e/SI@U3&
SA\[g.gJ9AcM/KM><OgYN@B?_94@I@Z7Y.JZ9C^I.(,U;CB)_AFfD^-PD3^O[095
]BIg40FRG^69J9cAO[;aN;cRCND#0BCd]F(4(d;aB@F;E?N6Q97bcZFMZ<H\7SbO
=-]dEJMK8JCESUJc??&V(>fIZF(L=BD6L_]K69--7L-)\W<fcH54cfY+\2,8NFD=
W-_V>N)cFM+4b8A,F-cE.+,:D_Z<e;(FC3;@I321GeN81MGD6)/7?<ae[TMaDX+=
DP;Gb=GSG(73GDX30_:TV(fg(O7#:[9c=G^CZ407D29QPD[FDE@95R^G.&@A5AE1
H.E8Qc\O5I8HQ?BN2,,-,82?EL+eEJbX)A;>#b:#(S^PcK,U=<8T(TVHKe30N195
aFR13MIS^<[Y5AG<EA\4)PD+HQ2Og)VbL@/ZgH?EUG(5_F59X0c:+B?1RbP1FaHd
@EccYWe5./Q:d73->gH7BbJ:CK^&[UI9UF3?)WR;Pfa0CI640+d1X(D/^V@&?F&D
^6E,#Mg4+=LXK][aWb8_)69CD2>?S/7.FL@[3g;X?;7[I2?)04/-Pf<S(PBI=-T#
E1c#c,I>6@8?59JH:>CbU9ege+cc0Y/^_ZPb;5U2Q+Q3=S^@[=fMOgVf+.6;aI/N
:?>.MGA)2^&G,?eK3I_C3BJ(<OI^;bOVbAIEI5B_0c[3[FfgYce+OID?:^I=LRP8
7>@S5C<_e_C=&D2MUbQ@E=IADfJ=VRJP<gDa>Ob<5T[&6#8L+=3_&e@g#@GcMRVU
P:+^WOP[[BBOPT@,8[6a_--JF-(]]NA@S\DH)da-TbfbB)7FE#b/.J&\LA_KJdDL
/3MbgL#T+UeSGX<fU:d<J2BE^K\Rf^3E#AM7bKa[SUC,/06eZ+VOc0DL;-9>0fEK
7dI];U&Gd;8]1,L0YNMg6F6V(3>0IZ9MSJ.=BM2XC5L>65([P\X)WFWU9TB#^J\b
B/=.L18/Y++0Y#HYWR?F.LT:MWA7U@4dgB#R]]EJRE/,?ON4P@FE/a/_.Q4Y7C#^
HP363,ISX:S0J@X)@6=NF;SVcDSYSA1Sa#&#dA(/3:;R?]]WX[9>L[+X8=)VE-B6
6MV[@]^b_b]-]Ed8-DA;/EC2BC4)b)5XPZP3M?AVM9bES:8V<,.8+EcfE_=U6Z0L
Ge0(aZ]X)VMOG.RLAC50^]R&@:;)eHRU&W7H)/Z6a?>_dO=N7&B0G4e[XTQ)=L&S
J<9#L\UV(J19d,#].3W=O>&L528///&JV?L4/DBE1O3B.2-.)].Z\3XA3>5QIM\M
9&[G^L#7d&FO+SU[:@A-/dN#37B24)#X7;<-9DKGTD6PS&CB?D^,4U:?,4e3X@:7
S8UME0H@(_A.MFIGJ8.8;;G4&/:a;8dN/8>5Off>4F7.bd6g(Y^GbZ-#-e<L\I5K
XbO3#EUB[E-9DK2S68P,-e<,X5eRVZ&DVKG8:^b\W#X/HO9F48WK4)]a<1+)<d0+
O]Wf1B=L4<RM[<6@4AeH?(9\@5PY+LZf^^@<MJ@,^bBPaX(<eJV6cMC,36CAaB3U
?#[ePL_Qa45#GgRf1WE:4ZOTK67^bB?)47:WTVabAB]1PeNS@^V3DS-Y6BbbJaR^
Vg:FE;]P0RPegCBX>SF50JQL\)Ub(XYR;3SS+a)+]dV(&KG(eSZ67C]7L314=6WK
931;8=<fc#V:Q=<^2F@]L,fR7CNZ&:e^S3R+0(H6@<,TO9L@:9dHO[RRIMS^6[UZ
EKBUbCFbA,Z3K/BS1SU:JBL+TV9GP<.OGA92\@D(@]@M<a1=@RJ0UTU@R&b/EJ65
Y1\0+Z1I[MY]#SH6eG-^XV[_;?K#b]7JBA,[<H)0W+V&X&JU44T.5-35UT&LWINb
@:Tb07S7gCH.]&+4#4/Q?2)3++a4b<Pb4BL;]Qg?5CR:-@P:b#S<>6DR:VYC]-W,
&0/MbM2-bL_I?U)ZY:-].MQ1ec^La_MF<a(X0Id:X\FX>D_>5\2.CVHUgcZ6aDG,
gTFDSFQ1D481McK5agM>GB?8F&dT#@QCe0I_]#3:NAA5]Qe49Q+E[=e_V#3\\YY4
7@+&9\#JHd3E\;8ABFV^-e)73;;S4W6;B2_-&JX-VCR+:.Xa.]J?;U<d3XXQEOg-
d#=Eg=Ac:gD)JB_5ZG=57Vgf^^(MH=aK#T8MdcaCa4A=E4&#OT;b?#9g+CIYB=AB
]7K(e#)NX2P.(0-W];7g^X@L92gTN?I:ZWe0,6N-Z;+2Jd_Q^ObS@<R((+Uc0ERa
1KEC;3L\/FW8ET&H2I&DN4g2W(;>RU(6FK(N<CeAN,I(EAHgG#3.c0F9&/Of/2?+
@<<1<d]e4IAI=H8:,efN3?M<W+XGG+SK2/Jc]Y,Q2J;(d]&&S.aRXIYU+Ca4dg9#
LFS]a.@X6QcV>;23;B8=d(:V.9RQB-Q6K[E&N<Jf#WZb\A^dZb#,O_B0PgM/E+4U
f<[XD[E#RTJ(D\gZ,@.f^.L&?c6B)QE8?TD>K[_S4_0cN?9c\:.@f]0:QUf6(>QI
Sf2;T?R7O35]BXZRbWK,)JS\N@M]gQXH2-YEPaGGaIb&6fTEA0IM]NFH<VWQBSc=
g]\=G/U1M&Ra<V<#gFS4BHSK_8CEV^5/[?J?Y.MA(G3,)-U85_6CBVSGgBY5J4d0
:Ed7K@[U7(Ygg&7N3Q8?;fB00X.&d+M#I.IL<3JS;^g;1U6GGW=g:;ga1DI9P>^/
F]R1^?(&Oa2Z>I4+)F,7g5Rf9<8a,D7f7,NAC0(LC#M27FHb3eE)#+aa_]K_(VfC
)<GC_T=FOJd.7WcM1)FN_CfGe@O/HgeU&+XTJa>/R<2D5LBKK3d#R)3(fIa,K:LR
ca.MbNcCRP\[94)@#9SWQ+a13R_Re+,&cMeB#B=b0JWQd)S>eXdS0#[QeZ(PA7ES
E^C.VC[0cN(/4S^7;e9d-7P#/L#3O3D<-2OKH\003;2X7(956-cV#GTK<JWg3[OV
^\f6NQN>P^-[cDHM98F;D[)ZO81S:?8g7G@&A/@EDTTPLB45W-R5IPJ&8(dP8MF9
;[WgL>>O+;\@ED.=B?U9\]bOI.@M]QR5\d@(UU<?eQgMDJPRAIX,XDcT?GUGH?F-
7N=7GNRINC)PFE(-HY:UDJ5YdJB<eQ2V:GAK_F#&f2+;WEfOM>aQcF9Q4VGZ650^
;J/ZR16Y^c?,0K.M9Cd&<,(4\<-_E/^<+P5CR0&>6N_7<29RIYbM_<>Ig-7#4RN0
40)Ygg#0b1U^JJRDZ5H37+eXN8[_]c#eV97IQ)9W-5BE12497J15G<3)bBBBd+)#
?2X:e(]32K<,SZ>TdTQUXRUE>^g@>/D]6H/3P8e421^dYgLN+^:)_W8A^;T&B6)]
?H2U&<N9MaJ02:O+ZF/U1?QN,:Be\52S:P&Jd_I[3>LLfJ/6TUYD6Z6,\CZeL=DC
M;9GOI93=V[A#O>+F29C?dIC-G;R?&)WgO@SU-AP]0X608Z]LUTUZ-/9LP0-/?UH
QTD]_4a1g4S4Ye^D8e/:b\c^]+,];,6HG@4;fB/@OaJ#[-/H;g:RX_]aGN<FgV[D
1L?CIaEP[b^dH=RVCD+GCMXV1<<8\@3?+gF99^LDRI\,cTA>GH;WQg9Lb<^ML8@N
e^d2YBVW1?7NcSf@;@+:5Wd5Zb-9SbdYbO_NI/(5DE2]L(L_9_a;29PP12c5T>YV
@C2,1-V=+:K(#K@YDFXN-:)Q,Z\2)<f#f[L0MbU\N)d5d<&Qb[RKIfY3G[P+3f-(
f78\HFJTYTdH1)=UNO(N<LS4;TF^03NP1cd..80,(S4EbO93fgA3ZA?+1-5BTSJM
fA9O-UX>P+R[U3=1)M#1,_[E4cAR#;PNb;;YJR61;YJ)e0UNT4aPI0F6NQ8-B\4T
;HYWS+f>fW(RV].8W9[Dg1VR:9B6:G&=.\f+0beE_&aMVOc0@GWP6^:FRD5^JXY[
&[YaSG16M[Mf(8]25a9PY]M24(<Q6H<;aUbU&P;3ONV),E18c/O0Q2Ge,\M]U+ZR
_QCJE+D.7._I8Z+CG6PLXe^C(\1;NQ.<)VZcS7MaC0=YNH8G^eFQ?KC)]=+_1VSG
fL8+gL?+IKg:ZJ=I?-WXLR\a&V#Q1aY(S)1.Ag,[Z/^C\J=(30cZ=7BL5<)EED]Q
SDP&e&Y)TK8]4F.)=>3S9QFZ]8bFIfMFM+8=Z<KK9WeM;[\d5XKWK<cgDW[H&-dg
9VF9#5?.gTfNR7R\c4SQ_;V:Q<1S,Z/+gX<[.O0E+6d)S,F[B2W.6F8feHg:#Z+5
7RD._T)\H>#X6KEM-6@K+4H7e+3@)&SX^[CB[E\O#GG(G-/<Gf2eGA=+WP\??(Eb
4gZJ2aD0FQMNKKR0TTaVV-:-:gFAM&^f?H2-E;GcN+1#GJe4(:?#<H^0[TFJ8ge9
dE:4473<P8A[5A[;)f/Z_AC,VMW_2[E.V>O2.-UIaLf]g3+gUUW^F\@+Z/Y@IP:+
0-4JA;49HF:@[W+a(KA2Sg[ID(HTO=X:H^&KI3Wa#+8:Y28dWP/1]W=(?NY8?7-^
L-[STF4R(BC,[\g4IWGWK.6Gf(9PWGKPL.-:(GX><3G_6g8RRY9cHLKXVdeb>^f.
0Z?OY_-)/c87Oc5Z.I9-)6:4NPc#ge.W.)GZFV#_LaDMG]P(<>SccgNZI9Gd]B?1
PU^;&RLY[>XRbMM;Q_&XdU,W\+^4H_X2F-3K1d(9f)&897dd_@Q37MgaHI--RMMI
[17&bWN<+76?b5P__UXS63+b)>ZL9,_=QE7A&V<&T339L\HB7)O(/QQ)EBFL=>f2
4S90?YUZ>_GL8DL>ddHbRT5X27S5AV4;B1WA:1bPKHJ-^^a&+Cc2J\gKX,&M61R#
^U[(\:\?-c4V0XM-J3TB./NU6edPdQP[AI4?P(<4-b_&^43MHB9fEcD,VS4eBd&7
5]7)W:?Z9P.HFTRTC#I<ISSY2U)R5L58P_8(39.M&daB7cJ^IS2[2C#2QXe9)6NF
JceF,(bLZSSAg(TBDJaDf1gI@<7@OEX]R7FD=\/JNIK#J]LMb=#42=P<ENe^RfVG
AbaJ(>C)92Lg8;)-3TD_/X]<dGg<P)AX(7NT5a((+Q&=3KX_T<2\1(/4Sf-KQ,e9
6[_+[S8/aIBRDa,HVT5B:5[9<+BSf15LID@=M;XM<G=,fWa+N@=8)OR/E\8f,]1e
V<ffgB]>K1d0?>\Q<G^CA+\(5(V;_0):gD@1]a=8S@b56R:M;:9,#J-4(N-Q5W4R
C<PLcQ/WCB>JDMG5;YFUF<9-DB1#X8[,1gA9,676IT=fKRAe:I:QWBMIYD@.SE)A
VF-bTMRC.F(T7/3f?8DD@ceE/;Xf-W&?c(W]#VMBP7R:UMI@:D#?2-]0BFZY^aJ\
-FQ<)@LS8Y5V4R]V(6Zgf[8KF4c:6/1&0)AYc2Z;01A8_3S\M74&9>1J&6-DeW5#
#4/<0]DLWO;>],)WI0=/P4Rcc0H<,M&]3U_RJNLH8-<#8-3HC[PCX>Lb3L6(V)7R
97VegDQULM4LTcT^RgD/]dYQ8:3/CdF,T@0:2W+B()WR;1#^6L:6=YZI_0KHPK9b
U:;]J4EA(S58Y;+d4<X6@1#f^C/9f7-2OKJ]0-D8FG5=\KK0?=5RN=OROQ<6>[EI
gJQP]YUDWL.;(NG;Lb67NO28);gLdG_X7ZP(<E_5#3b?YZRS;J?VDOO#.6Y@@:C(
G^H:Xff+6d>eg.Db3dUN>-49;fPUE/:@\3fVZ(E-UHO3cT\I<JY+eX:Q\Ue3Bf=Q
E>dc&C^^P,,JI3#HG]OZL)Ja6Dd_LH(-;,XCV\Fb\&P^@(KfFPHCFYE;?OA7QH0?
\-I+7QNZC,0?PELTT9\1Cag38KB5b56#=BU/0+f0.-CV:0TdA2GD.OB;eeX3/Q2+
aeOFND/&Dc-D7>4Pa:;d;c&Ng2>PHP-YQ@,c9&KB9CWO=#Pf6TaRf_693&SWPNdA
[/c>=I=cHN0R-0)M+C?9e-R8FC,F9TgYG^[1,EA3^QR3a]c]HOU\L>I#8SeQK-a>
?A8Uc/=eD,4:#&W?>dSJ>=#7_MOO0:_-(K@4ECQF=#D:QKGMA2eHU6+WPb)BQ5?\
;abW;fVdG@2&Xc\DY@+^d+EUR.EV#/eH##>:ZW;PDf/&9<A5#==D&&2&deG09Q;C
/ROCKD_:D:RY[I)^A804,?WBVX7L.+C;C;4?V)E0-CH,.XQH1H:G+;3gZ7,TO,HQ
b:59>e-NV;&FR=#]fUbB-1A6W<D-ODH-H<8;3:a<Cd^HF6<Ma[[Z[cC=EOgP,CR6
G.:@/F@gYXA[eVgW_0A2=K\DgOD13=8fO+M&)gD?RGSCTPKY92TXf[5c[3b6,(]S
G.<R6&c=c?-()eV,6<6[S&LCO5c@f]XUH8]NbUfZM;&Y_68Tc#:>@9f/P35If):,
/0_\^\3GV7Q81@&]JL\15d39I^fbZ2OdE;V^)Q?\D+\Q@dNQeN,IU.2b,JYBMbN6
+]<[5[G]>IbV,/#OJO.:91Ga]WT:0674DcY+,OABUg.&4NZ<+;GOVYX\bd@10>D<
;4_8>da2CI&W)^XeO2U2JQcL\5<X<UWTUc-OL9E\^ENLEF&#0O]35OP-G.La4B@E
FK7:Z+&bBBX=;_IR&=.E811SY4,>W23S=4OLJ3^2fN<OO[Z.405eg/J>dKbbT3]e
:HYU6+WC0(,#.cWJ#9FF4G.\Be)FO8<J+ag&Q=J(R<&-fab\#UATQV?SUGg;)bK-
cVHPC?J90GGSYTZ9FP=_]/aP<\<)\ME#K;H@FK-9b,U[#P#@V;;T+gaS\@/VL11Q
Y[gMC?IQO]N9[SaBDgM^>3#:S5fE[Z\8#TIF-/eYb,(BcXN?#Z:W6LJe:?Vb-;;7
^2T22)5>0:gb-T.MC\@#A95cNgPLLPUA]4We^3PS)c?Z6d7^^Q<QL/S<aX]27&B?
IIe50HY)]LPE15EM]87CSYfM_V::_e-8=bX6Y/+NZ8JPWW?fAN12cWDNUK_[AJ?:
6Z?T@H?cAEEB;;)>BX854#KS(VOcSgbaGQ8:QN]\a+;PFW/3@PQHc&A?43+=-(79
X_](f+,J;4)A/0QZ/M2V0B[+;Y3(^XF?),5ffCgHC7fM@]3.M;97gaNc@R;Y>GB1
d?-E0gQ,=](D3)Pe8O>/g]T)]0ZT;\_cG::_5KBG.]F?bK:#:Ic)0NaL36Ab,A70
8YM[0gNQ=Z^P>7<ZcR4;4=B5WK6M1L=+/@F2=_C;++&IKB4_X-R9#\Q;-.AZSXU9
+d14AE?]NUJ;O@?-@V+#IFFXD.bf97?aMX\fW8)WHVa:54#5c1S>YSY)N_MD^C34
?ge@,/R6B_?TGQ02)=3=P9R01PU9gZ1]Y6V9IJU]NfAe\TNg,^0BGYP<_Z>J8C&5
D]cc#Ua\g;_-VDQKd#A2;\d08SOLC,A]QS&&WZXbUa:<1f;YYK/M<T/#7I[9^3.T
3aV&&P1Mf>)[b^&fW#6PNOB\Y/7dEVCTK.c2.#>LAR)1dHXIC7(6SU&57bO-P/Og
Z7FGFcSY,,U62W1?,4IW7/cM=T:Ue\P&)?A@e6,C9Q&Q7A2G<M=FK_a<\+])A&M]
3[8(R<+aXaF=E;7B/M]aQHNUdXJ4)]]QX_&5CbQbbA[OBSS4+ATF5M^Z1Id)ZgCP
BXJ(3V8b+:V/7NJR-6LXL_02Xc^;#B[6eM;cSYA0A<XV/QP#,YNbb@Ta-:KR?Q5O
:2RUY=C@2:.?(XaIMb0X4UZJ3E<7Re@_[.5RJVI)P)A30\2##<+9BC2c]SL\AK0W
KF5.c&7XO-<?S-T?K,gaF2(EY2(Q<=NA)_R0DAJaTE_^&:=Ha5UG4LYRF?Z0V[96
d]Jg3T3+B>^a8&Kf+Zb7e8M&gSAWVPF^c5=QR5ec9+&3,D?<U+;U-Ld&fA,+(:F2
VK6,b6E2L+@HI\@]6V4_3aJ[dCPL7^FD>&Eca2Z2I)PK#_Y+ITJPD:((GF_8@.7d
d>@5A&+8LX7\g^JXL&?E&BV6V?8G8a=V8[eJZ;B5:P5;C)LTg?HeK@VOZP)U(H3P
QQ]4#&(;]3;OfAgWG?JR]7Y4a&+=5M:6?RW&,5Y,8EG60[#b]fJLcPeRdT;Z931K
?WTR5F[+Z7;AMFe;XL@T>YJ4G[dBb57?Z7Q4>TZD;@W9_]/1&LEUB=\4WfH)W^,]
#f<<_E,9\6WYcE[W.+gP)KV=L]\eIWSbG.6LDL\-((9LHa<QLV@OgW+R&6_FYaB-
T=D36LN.O,Hf,PEDNa9CE+@1?P\+M=PX&@YOEP>FC4SI5J^CN#[F#<]ROIR2\f7Y
fcCA3aDB.DEUCT^YL[Og=RT5.DA=1];V1QC)dUHE=1X02,dT2&A(Jb6#JQ,DbF(b
YWfEN<A^EHf)YR+:+6-SEL-@_\fPYW^SL+BF\&LY+1?2Od[MS#gAYJ[<FMIbf<f>
Q<+LWZ>>X,McD,[7AB(&M_2_UaFROZ8\3bXd-IQX)=I?a(3MY<\MGPS(B@[(Z@/Z
I@7CH6[GZQ0<Ic.?[_N6XFR;H4>U5PgSI^[JNP5#GW/(@a3ge_6-,U2VfV]@4&,9
;]Zf4R;G.6fYHK_aU/3&L[9_IY_d9fGZ9#[(b3IGP:;7U\cA50IQgU>4>^N[&#KY
,J9cc;C>^aPGC,P:cSKgVW_=@g(_QKUf._V##6@X]d37C^US@YDX\IV=DN>f00K=
;C_ce0:#&A3.G0+f:&C+Z\_7#X6G<<ZA_.Sa.6S:+)]ANfIFWg3]8Q/@4/H2N.)[
A-/C-\_bO,L;2bc9E#G-&bYFXK5N=_GZNB=10-A\U&I8CY)JegbIK788\a2SFCC,
gIXSN:->f-b8&2[Q?9N0WTG@6>HTEVFN;#XU^O2PgX2VeF&\.f?D#\CBW2gBbE@Q
4LEKKO_Z>Se>KAg&H4M>Z_S5?>;PV7:#:3SW9\:]]=.g4LPf7d>S86]T^Rfa]MZ2
g-WR-]9fVGJETX4UWPL\=7T9g-g(I:\_5;S=(f>&8\.,N[EUBKLBCFFY<\He&XD_
QSOGK:NN?7RS/[_J99L9L(fb4(bbO@&?,M/;<e5G@dHSA6/K2c>NFR6QV0:I)]L6
&^f7DGMBIE^eHEZGHSB8#H)->YaEE@#75-6P\G^U11._,K\5AFS-;70aaL.Z+:+V
^F<aP-RJBDA5@9^)L5,K9X4[D7[RW<gK[SZH6c\2;;/DCGQX<<#,;JH:e64@BE=0
^P=[4_UJ)\1fV/W6=Lc92HX/[FQ(fOL9/S<[/UbH6c-5fS:(1e4K1>fSZ,_WeR4F
Q4b/[Ta:0R1YGC#?L;CMDK(]&F\6PT1J-8cKXM+6/T:[P38^@W/]JSA_<591T\-D
?/CD8G=..<aE]A1^a?^NaXQ6)L--.=PScGb_Q2W@H/g&c4d5=f4DR3ObfG]aGM=0
2V9b<Te85_@,I6B[/2/gTaB0G\E(@.5Y<0;=LM\Rc(I=YIZ\+&QJMe0]<,+N,R>X
F5AH=9bH0g2cPd03IB-d4C-A+)N/VL(=64a3,EJ=)a:]400]?0]R97B7SLF&eCE=
Q#=1LW+_[dJgAK/KJ]S9X4[MB\FVb/,:F@:1@7#edET_WY>O&LVU4BET)=WMU-M5
7>OWaga)I?d<#WW:HQZS2RT.^SS]9g-PJ[5FARG3)RM8D)V#I_=.N=FU;Dg.O->[
;;68M)T.L=VG3Ub>8^1[]/LU1R#5/(d2-NL0Xe]@V1]9QJ;<KY;\Z:2[26PJag7V
U#d77\<EH4Ue?9\,L#d55R<+\H_0;c4OH380VTBH(c)^TDTL5]6H1fe4E7W7(cZ8
I^cb9#NZe7ZHc.0LO__AB+Q8T]Ka^Ve^+,(Z<\Fegg6.J^4LC#S@AISOZU0/1W\d
b61UXXM6cO44QF?ETQ(PXVa/fO61dRU0.[(0LK+IIV,1S4W?a3?aBYFRW^-C;D_/
g>D:;F+OAb8_\cfKQP1U4P=MP#ga(T;[0SOf@S@g^FfLKbJJI2>^2TYcdNZ7KI?O
03NW,;(JH>7,OR5?=@U?HBfAU@&G:E/_Q1([U\dXBE()HOTX?X,ONF9,[-UQUgIX
A<@&E?7d&cZ?2:=bOfe.JfKW>5B-B12Ee^GfF#RfPT231E&M@e.SKSNOcHYL;?ST
@+X]?IPe3@e-]I2MJ#6\ZO=Y)f+MDgCWF=1?]^2=BZGU5K5FWMJXLOFQQ2cVX/X)
AOG#^Oe(PMX]cNVa]RJ8WC_B2\3Z5=)PXK;Z8Ha<[B[c=(1/R\96P&.BKAK]>5HD
;EX-dEJEL)^Jae?CN/Q5b^8378K13M->->=LHM#ZGZ6K62A_8+0,D57WbER3HI:[
F,IAEQM.]^R08)DV\68&1gV5f/;4^@ccXVLAg)5(B7P)@KE>Mb1^Xa6?C]?YYCNY
Y([]O#8[:EabSa2Q@5-fQ7GZ(KNR6Xe)a#0f2<cdCf0X@GA)6S.5]I5WaTS>G]Rd
cKSZLK_1ZKLYGXRZ7fJP8;NFS<?eFJ+ZgH430VIe+NE82\=Z_/A9<.J37\cT,M5K
@R/MKf(96Ncg(7?(-Rb/,EFBLZF&\c@E=BGIVXCAVdRedW1F&?^8-P<?A@I9IbYE
(POA3=J/USJE=aL+[,W(e8>X=KV;DWFMT?C6B0K0:(D:,3Sd8MU.F8Xb,N4F1GdR
AMN&J>[_e<FU,<@&=Eb;-FP+J2KBEKG9\ENVc?J]+SVNEZG,>/cL>+b.fY]1]_c)
N-)&+0X2/KCJ[^H#FWWHSV\6,@]eN/H2dGcBL(3DUNG+g2HF]2W8Jg=OP0]^Z.?A
<b@4I)\bU0,J8K[Z+H@;U0#4H<+K)HMWe^UFRJ+B1fV>\a/RMEeb^:9][=^V>C1V
=-O?2X:PRcHZG6B974_82?_cUVNfZ>>_+.AW+VD7J2;1/N9)V?aN+IQ?aM;T([K\
M#?1>6-?P3:g,+1VGdH1M_5N7+V^C/,S_GZXNNJJe405KQMQ(X0U4ccX^2EY0?/2
US_;GIA;[E\c+eC>=TT;8W6fZ>44BN3.&[]0KSPYO9[&,Nc?e7S3KdZb]C9J/=OZ
B>R:>.5^.V/BS6LX\Y3727#WYA>H+:S0)R7H,V1;FR0ETY+79]^YD?fe)]>a5;/g
[Y5ad;aA:C3]\+,5WZ)91UZF@,<0JY44O]beC6<02Mg_(B1[ZUcIfD2CR2a9gg&/
B><d9eWSD_([VU2O.f])IcHcP:MRB=,:M&2+VGX1?:MeM9:XT(.6#\\3Ge9EdI6?
G]E\9HNe<Z]CABebJ9BOEe@Bg.29I5N2<1[UVL(UN9?;HE3,GV?H;DFG4(DPS4F;
f(4G44WHOE=-L=+@58@[+U\I+H#^\JcYJOIOdc>:)XJ9)TDPL\]F>ORcA:Z))CMc
^IJLH_L-9L:E]#@>ba2]#I&F._MNEACDIb)gdYXD[AH@DS\3GgQ);RDeeAA0ZZ0,
[ENE.)_Q.8#RU]M5N\@>)fIK;Rb[4@OU?23@5M&3a^6;_]G\<<&XSLKH1^=8a-M\
Eae:K9@-U^(\LNV[44[AbaIB/E5N4f#eL=^IcWeHRYN)5Ue?,EWb94/cF)/D>R=H
/M(,N1UbVOOO3I>cWR&=N]EG06Lc+^\M^JGIafSQd0<5QM+^R#:2IYJ@NV#3d<WX
:D^S:K@Rb3KBGT^?O,7e#_2^2E2U+b&A>f/_PYLWTL9eQ1Q@?,g>4_8-I492R7T^
<Ha3?OX_ND@#D]/^LaMEK5^3^d5)U.)Ja;]NZG[>?GXe7DP\Cd>Eeg)0&X[H/,OB
C+2<M:Xa.)_E:91LcX683OXC,]G#\c9_>OYGPWd3]_WABAHL\e\W.X7Qa2.8U./+
9W5e0g+/P89ZRX#&bQ0:?.(16UI3=)Pb/0R#Q+:4]N<IaYc1Z8UJGf_@_g:SMUI?
7C\S#@fPWZ\:N;\JCWK?S(.THL#b8e]8TLQ-MM/c@b]YKW>N@NYcRa6UM3V=X7X8
:(<\+NPZ]M<)g55[J=3)N)SKdfeHVQO_STf0K\ZOTd^PMK&29[22KZY#,YT?KM@S
XX6;P3.&?O6NW>)&/EdKSQZ&A:7@)P=?>1#>]XNI.UH9/-G?K]JgS09.3&>#>:FF
cO8:UCLO;_,,HCKd1W@WFTfD3SXeTa1+N(g\DM-AIADCTM<;Z?\#cbg?#5c.dPR8
6e(A8ba0<ME-6]E([--D9;KRE56]JX)b):IMa?438RGIE+FPR#2^dN&3@H1E91JN
[W\W13@@66OKT)L-8(La^546<A4H?=2SLMcE2gYdDde\>_ATgKYf06dE/#a6Q3N_
0^eL-MV:HB_P[ZBgecV_#(FgOB<=36S4gH+BVfJVJEI5Q]P-^TFXeYUbM@HC[(\^
cRYSHZ)=\5.4e#6AaW@]CQ:CR\4S6ad(#+2@B-=WRa34K=4\HbJ2VMGNOcX3U6HC
0S>d/e^5^0BCO.a_CE>K.>3,0UCXcPJ[O3a]DN^(ZeE[Wf#F1/;0[^](9I>RLNLN
6;:;[K;48C039<1C]/>[?aZ;=H>EBe@/gEa.(a<b/X8PUE[\6G/OLZ)+IEd6W>[O
H=]]XfFMd&aE^X9>DL]Ma1K8OZ1BQ+IOH2U=,.FZ.EKD;J?NV173&bSaGD@6\6+0
M?TZ<VV90>bOKHKdYS7V\<J6&2=0:c1+e6HD0&DID-&M/QO5\TFdWSA,--eaWXE)
:<TAWbAU)UP?.c2c\]&fWN)6N>LVT2F3#H\V;dYQgKYT2AaN#QL8I2FA#&,P,I7=
B._6-;b>_TTfS3IN585@7RecB?.#\LB_,5X2UJUOCST;XgVNee?E7<,&NO@/S,9S
OT)KE+gQP/ZQ3P?TH?-=GL^R5bUAVR-9f4Y:ATRIRde&0V+fZOZ,LNR/&[EW428I
>><#@+.:73+V9\@H0(L+GCe&E?bNe:#cWaU^a=[+)R]/bRHD,cUK\FN+M00-a0d?
=f)_SJ.RTRgeV&+S,Q(LRIFO;XH;C8FT(af?Hb&.]HQ2Yea=e9de&+08LO+YB-;Z
DW4R>2A&5\9g68HU)0\E5,S_59#D^Y?[He/APO5J:).RgPQZD]C/)NIG3(0V;ADL
@=1aE.bQ077X;>-\4G3\G^\POL:6Xa3\F1FdBa&S;ISQV:c]QeKDAc:#]>VC@@&H
IF]KCN<BDWRM,f-/WELfW+1JF;@^TM0Sd^fX>d?BPKBM?X@4)-(M=?VAZ2eg1DVF
3H-e.a\X9dB:PG[)E/2RJ7/>fTYDe<=MJWWg6E<,Y>.=7]DT8#e1?92a#&a9dU3e
K@OS-gUBM)RA3(&,4aD?X3))@S>Y(74c)b^8gQ,G[JK_;M^ID<I?J+A/-@SfX&^7
RJge7VJXCF62N28b9DS@)BKCSaY@bRe?cY-A4]]d360?&X4BBUE:dPX_gODc0-1e
89LRL^)<\8_;CI_AX&E4Y1>2NS1)8#_+&SPB,5;+ZMeGFQY?5,Y\IeC=Z:\^(.a.
5FZIALWA8D68M+4UU7Bc,30+3=9aDR[B51-U>V)Z(S8X)A=EF_6(L/Ta8+&S0@GY
VYC:@:\04(aZ<cFEN_^NdQUX,5de?=[?bHY^6#8cTBJ^;GK<L))(deI.#.V2P]eM
9+S:)9+]^c@c#SO2O15a?#]O769#FU]OXYET<AR>abFF)?P@N4Ua#F]aH<D0+P5J
(B[YX>91c\4SReYgcTW[=8G6E:eZ3eA(d,ZR\b#B^3]-LY<RZ/#7]f,gUFD73W4P
^O.:]N1YX)cF>V8&-aMXf)]+<#+09,dY4S<5\6(:g4+4,R[X79bO,X>.=].R,0<+
=?E>UIVa[[O^A.(3;<dMZ#NKVBd;)#7&AabX/a@FZ<0@9,R3V97[Z@ee3KGU>OS?
JK^3-;Xb5b9-&.XR^N_S9UX(F5YOS^A;U<AT9K6?#@</(e,PX9bH_\QCPZ]DDadR
MWSa)881,dFc.RZX6/d&L_M]g;7T&\4HBH/deAe\GPeZf89E]MNbfU=Nc/4^+G>;
JBe8)QBd:c98NBbW>#4GSH;/Q/8#VA,[cZH1R\K]L3Z\ZJ/ES7XW5M=5,X(Z]:f^
Jd28,FbYUL]/aLM&P8W;e2LEK4a?CG],]K<BTHDOaGG(8<GC2FP;cG>XK64Q,.YS
gKC6-#@O0;bDb^-_1B/Q)NbH)^U#QT&V\KaP10>2bYFg:Qd&3fSRTG4\ZJ_b>79b
:VH.>7Pbe(6GRBMEFTIST9>1LS:GeRH5:Jc5#/8Y(S)+#W?]X.Bga3?;O[/ZVE)M
/67P/CLe?;0W]D)CMBROK-Bba^3@IP.D3G[@;2-<c4L>dR50=WKeRIC+K(3QV@>8
MKMAA6>GG?8f?Ra2\DQ9PB5;3^]:Q+SIU1^[GA==0#X:[g6fP[Z3]1DP9K6],WBD
<]=CW=_#:Ce>I&HR>@0[R?I^/fG9^aag@-9;M6<caA-<F@Y@^;V_[DN84CG/T@0^
d[;Q=.JE:>^,aCY6IcDFK(B8e/&ZOWTQ4J+PaZM[?eePD;^X?Q\ce4E9F.ZY<Q.B
cA1),F0X9fD)K&/fbD65I;a[b\;&)1bO@90)(#b;2gFNX,f_Jd5gV<L+8IfaA(C)
STa]K)\6>)Lfe7JF@:DQJNSJOLePPD9b1)/ME-(GHMJ+C4fgb1:13?]J[9.EDPRO
39AAC3HDOJ/W/PZ&>d[@M8f@-JgD:0#egXg6Bf.W#cW(^FS<MP;[;d5ERC)XCg4,
_/.2^@-00UX,/#bIB,-V=-8Ed,.)9(g8S+.E#8g+U]Kc(b5#E)Q#YR;VTW:eB-7/
Y4VC3YPYE1P;M\[+BMRMEJ6Hdc4<KFd/?\7fAfQb^<8Ka2.VH+f[AbU-<VIDbBBD
.1#VD9R_0M#XT5AZ1c>+:.YF(L](G.J/_=8<P.XTUKN,MS3#/49XDL7AU:IaG#A5
6^V4ELYVd5[JMY<aA\5OD(f/G;;gH[(NWZ\7[8KY2Y9@0>(_g3XOYW0c55g:ATG[
\QWdP_Z&7Af&:6D03X>BQUcVBaIAGKM63\XG26SOg-40OJW[<cITTV,(#If^\dS_
])H>faFHU08L)/X44Lf-5)Z&+7B3/511M?L1?E@YW36Te27feSF9WK4EH8Eac(1O
NTG<;H_1a@3[XK-7).2]AAUB(P37c[69PcgWO+03bWb9N&,B&&OYdQ[MM?1JO_H^
OSBTc\d4.\-dP(KGLT]>>d98(de=MRdAc>]]T\T=NF1a.N#MSATPJbbg\=>HcVO&
R:H3DcZ[68=E(@N@_+d-,S47+2f7070&\BaJ6bVELaWR<7EfU+AP),<HXYf0-L^5
P]4>#-V6&;K24cD9H^QA]SQ@\cQX5BL1@B:9Z_)IZM+a,R8-VQ?#?BQ?KT9;2_.2
W1=YFHSe3W2K.>=AWZ25F4;eS@N.S9I\X9AJF^7U&L6V/.GG+<[f)aH-.]F,L1)-
(g_A.e<cQe21F@OCI5J7CeY=U#&EDaMYBILeEH+,O9Bf)R5deeI+H],A>DO24PU1
7:;<?D1C3XM[0.>B30<M>\ZYS7FNC>BBXLR<LRK;ZTTI]AY4(BPT>7384_H0?7<D
.YA5gQDXNO;B;SKY>g(?9?UJeK&O=-/L<ZB46@6GfHZZ@>+SV?JJ=X4NG:C+fXFQ
G_@W^:J^B5_\N(3e1>.T.X15S>I.Ze0#RPD_2_9A2E\XS.e);>-C(YVZ1L5YE?N\U$
`endprotected
endmodule


