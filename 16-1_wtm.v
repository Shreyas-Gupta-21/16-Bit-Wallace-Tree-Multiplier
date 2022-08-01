module Wtm(output [3:0] ans,input [15:0] X,Y);
    wire [15:0] p0;
    integer i,j;
    reg p[15:0][15:0] ;

// layer 0 (partial product generation)
    always @(X or Y) //@* begin
    begin
        for (i=0; i<=15; i=i+1)
            for (j=0; j<=15; j=j+1)
                p[j][i] <= X[j] & Y[i];
                //$display("%d",p[j][i]);        
    end

    assign p0 = {p[0][0] , p[0][1], p[0][2] ,p[0][3], p[0][4] ,p[0][5] ,p[0][6],p[0][7] ,p[0][8] ,p[0][9], p[0][10], p[0][11], p[0][12], p[0][13], p[0][14], p[0][15]}; 
    

//(partial product reduction for P0)
// layer 1
    wire [15:0]s0,c0;
    approx_fa ap1(s0[1],c0[4],p[0][2], p[0][1], p[0][0]);
    approx_fa ap2(s0[2],c0[3],p[0][5], p[0][4], p[0][3]);
    approx_fa ap3(s0[4],c0[2],p[0][8], p[0][7], p[0][6]);
    approx_fa ap4(s0[3],c0[1],p[0][11], p[0][10], p[0][9]);
    approx_fa ap5(s0[0],c0[0],p[0][14], p[0][13], p[0][12]);

// layer 2
    wire [2:0]s_0,c_0;
    wire g1,g2,g3,g4;    
    wire h1,h2,h3,h4;

    // generation of s_0
    XOR4 xor1(s_0[0],s0[1],s0[2],s0[3],s0[4],s0[0]);

    assign g1 = (s0[1] | (~(s0[1]^s0[2]) ) );
    assign g2 = (s0[3] |   (s0[1]^s0[2]) );
    assign g3 = (s0[4] | (~(s0[1]^s0[2]^s0[3]^s0[4]) ) );
    assign g4 = (s0[5] | (s0[1]^s0[2]^s0[3]^s0[4] ) );
    assign s_0[1] = g1 & g2 & g3 & g4; 

    and a1(s_0[2],s0[4],s0[3]);

    // generation of c_0
    XOR4 xor2(c_0[0],c0[1],c0[2],c0[3],c0[4],c0[0]);

    assign h1 = (c0[1] | (~(c0[1]^c0[2]) ) );
    assign h2 = (c0[3] |   (c0[1]^c0[2]) );
    assign h3 = (c0[4] | (~(c0[1]^c0[2]^c0[3]^c0[4]) ) );
    assign h4 = (c0[5] | (c0[1]^c0[2]^c0[3]^c0[4] ) );
    assign c_0[1] = h1 & h2 & h3 & h4;

    and a2(c_0[2],c0[4],c0[3]);    

// layer 3
    wire [3:0]B;
    wire carryout;
    wire cin=0;
    ksa4 k1(c_0,s_0,cin,B, carryout); 

    assign ans = B;   

endmodule    


module approx_fa(output sum,cout,input x,y,cin);
    wire s1,c1,c2;
    or o1(s1,x,y);
    xor x1(sum,s1,cin);
    and a1(cout,s1,cin);

endmodule

module XOR4 (output f, input a, input b, input c, input d,input e);
    assign f = a ^ b ^ c ^ d ^ e; // ^ is the XOR operator
endmodule


module ksa4(input [2:0]a,input [2:0]s,input cin,output [3:0]B,output carryout );
    wire [3:0] p,g,cp,cg,ccg,ccp,c;
    //initial processing
    assign p=a^s;
    assign g=a&s;

    //production of carry
    assign cg[0]=(g[0]);
    assign cp[0]=(p[0]);

    assign cg[1]=(p[1]&g[0])|g[1];
    assign cp[1]=(p[1]&p[0]);

    assign cg[2]=(p[2]&g[1])|g[2];
    assign cp[2]=p[2]&p[1];

    assign cg[3]=(p[3]&g[2])|g[3];
    assign cp[3]=p[3]&p[2];

    assign ccg[0]=cg[0];
    assign ccp[0]=cp[0];

    assign ccg[1]=cg[1];
    assign ccp[1]=cp[1];

    assign ccg[2]=(cp[2]&cg[0])|cg[2];
    assign ccp[2]=cp[2]&cp[0];

    assign ccg[3]=(cp[3]&cg[1])|cg[3];
    assign ccp[3]=cp[3]&cp[1];

    //finall processing
    assign c=ccg;
    assign B[0]=p[0]^cin;
    assign B[1]=p[1]^c[0];
    assign B[2]=p[2]^c[1];
    assign B[3]=p[3]^c[2];
    assign carryout=c[3];

endmodule
