<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan3e" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="rx" />
        <signal name="XLXN_8" />
        <signal name="c8" />
        <signal name="A0" />
        <signal name="XLXN_53(7:0)" />
        <signal name="XLXN_57" />
        <signal name="XLXN_59" />
        <signal name="XLXN_60" />
        <signal name="XLXN_61" />
        <signal name="XLXN_62(0:0)" />
        <signal name="XLXN_63" />
        <signal name="XLXN_66" />
        <signal name="XLXN_68" />
        <signal name="XLXN_70" />
        <signal name="XLXN_71" />
        <signal name="XLXN_74" />
        <signal name="XLXN_75" />
        <signal name="clk" />
        <signal name="XLXN_80" />
        <port polarity="Input" name="rx" />
        <port polarity="Output" name="c8" />
        <port polarity="Output" name="A0" />
        <port polarity="Input" name="clk" />
        <blockdef name="baud_gen">
            <timestamp>2013-3-23T14:20:3</timestamp>
            <rect width="256" x="64" y="-64" height="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
        </blockdef>
        <blockdef name="uart_rx">
            <timestamp>2013-3-23T14:20:8</timestamp>
            <rect width="304" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="432" y1="-160" y2="-160" x1="368" />
            <rect width="64" x="368" y="-44" height="24" />
            <line x2="432" y1="-32" y2="-32" x1="368" />
        </blockdef>
        <blockdef name="clk_mult">
            <timestamp>2013-3-31T17:38:51</timestamp>
            <rect width="336" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="464" y1="-160" y2="-160" x1="400" />
            <line x2="464" y1="-96" y2="-96" x1="400" />
            <line x2="464" y1="-32" y2="-32" x1="400" />
        </blockdef>
        <blockdef name="vcc">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-32" y2="-64" x1="64" />
            <line x2="64" y1="0" y2="-32" x1="64" />
            <line x2="32" y1="-64" y2="-64" x1="96" />
        </blockdef>
        <blockdef name="rx_fifo">
            <timestamp>2013-3-30T14:52:34</timestamp>
            <rect width="272" x="32" y="32" height="536" />
            <line x2="32" y1="112" y2="112" x1="0" />
            <line x2="32" y1="208" y2="208" x1="0" />
            <line x2="32" y1="240" y2="240" style="linewidth:W" x1="0" />
            <line x2="32" y1="272" y2="272" x1="0" />
            <line x2="32" y1="464" y2="464" x1="0" />
            <line x2="304" y1="208" y2="208" x1="336" />
            <line x2="304" y1="240" y2="240" style="linewidth:W" x1="336" />
            <line x2="304" y1="272" y2="272" x1="336" />
            <line x2="304" y1="464" y2="464" x1="336" />
        </blockdef>
        <blockdef name="LED_TX">
            <timestamp>2013-3-30T14:55:0</timestamp>
            <line x2="384" y1="224" y2="224" x1="320" />
            <line x2="384" y1="160" y2="160" x1="320" />
            <line x2="384" y1="96" y2="96" x1="320" />
            <line x2="384" y1="32" y2="32" x1="320" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-224" y2="-224" x1="320" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
            <rect width="256" x="64" y="-256" height="512" />
        </blockdef>
        <block symbolname="baud_gen" name="XLXI_1">
            <blockpin signalname="XLXN_74" name="clk" />
            <blockpin signalname="XLXN_68" name="baud" />
        </block>
        <block symbolname="uart_rx" name="XLXI_2">
            <blockpin signalname="rx" name="serial_in" />
            <blockpin signalname="XLXN_8" name="en_16_x_baud" />
            <blockpin signalname="XLXN_68" name="clk" />
            <blockpin signalname="XLXN_70" name="data_strobe" />
            <blockpin signalname="XLXN_53(7:0)" name="data_out(7:0)" />
        </block>
        <block symbolname="clk_mult" name="XLXI_3">
            <blockpin name="RST_IN" />
            <blockpin signalname="clk" name="CLKIN_IN" />
            <blockpin signalname="XLXN_74" name="CLKFX_OUT" />
            <blockpin name="CLKIN_IBUFG_OUT" />
            <blockpin name="CLK0_OUT" />
        </block>
        <block symbolname="vcc" name="XLXI_5">
            <blockpin signalname="XLXN_8" name="P" />
        </block>
        <block symbolname="rx_fifo" name="XLXI_7">
            <blockpin signalname="XLXN_63" name="rst" />
            <blockpin signalname="XLXN_70" name="wr_clk" />
            <blockpin signalname="XLXN_53(7:0)" name="din(7:0)" />
            <blockpin signalname="XLXN_66" name="wr_en" />
            <blockpin signalname="XLXN_61" name="full" />
            <blockpin signalname="XLXN_57" name="rd_clk" />
            <blockpin signalname="XLXN_62(0:0)" name="dout(0:0)" />
            <blockpin signalname="XLXN_59" name="rd_en" />
            <blockpin signalname="XLXN_60" name="empty" />
        </block>
        <block symbolname="LED_TX" name="XLXI_8">
            <blockpin signalname="XLXN_74" name="clk" />
            <blockpin signalname="XLXN_62(0:0)" name="inpt" />
            <blockpin signalname="XLXN_61" name="fifo_full" />
            <blockpin signalname="XLXN_60" name="fifo_empty" />
            <blockpin signalname="XLXN_57" name="fifo_clk" />
            <blockpin signalname="XLXN_66" name="we" />
            <blockpin signalname="XLXN_59" name="re" />
            <blockpin signalname="c8" name="led_out" />
            <blockpin signalname="A0" name="tx" />
            <blockpin signalname="XLXN_63" name="fifo_reset" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="7040" height="5440">
        <instance x="1072" y="2032" name="XLXI_3" orien="R0">
        </instance>
        <instance x="2048" y="1904" name="XLXI_2" orien="R0">
        </instance>
        <branch name="rx">
            <wire x2="2048" y1="1744" y2="1744" x1="2016" />
        </branch>
        <iomarker fontsize="28" x="2016" y="1744" name="rx" orien="R180" />
        <instance x="1856" y="1728" name="XLXI_5" orien="R0" />
        <branch name="XLXN_8">
            <wire x2="1920" y1="1728" y2="1808" x1="1920" />
            <wire x2="2048" y1="1808" y2="1808" x1="1920" />
        </branch>
        <instance x="3584" y="1904" name="XLXI_8" orien="R0">
        </instance>
        <branch name="c8">
            <wire x2="4144" y1="1936" y2="1936" x1="3968" />
        </branch>
        <branch name="A0">
            <wire x2="4144" y1="1872" y2="1872" x1="3968" />
        </branch>
        <iomarker fontsize="28" x="4144" y="1936" name="c8" orien="R0" />
        <iomarker fontsize="28" x="4144" y="1872" name="A0" orien="R0" />
        <branch name="XLXN_53(7:0)">
            <wire x2="2608" y1="1872" y2="1872" x1="2480" />
            <wire x2="2608" y1="1840" y2="1872" x1="2608" />
            <wire x2="2800" y1="1840" y2="1840" x1="2608" />
        </branch>
        <instance x="2800" y="1600" name="XLXI_7" orien="R0">
        </instance>
        <branch name="XLXN_57">
            <wire x2="3200" y1="1808" y2="1808" x1="3136" />
            <wire x2="3200" y1="1808" y2="2176" x1="3200" />
            <wire x2="4048" y1="2176" y2="2176" x1="3200" />
            <wire x2="4048" y1="1680" y2="1680" x1="3968" />
            <wire x2="4048" y1="1680" y2="2176" x1="4048" />
        </branch>
        <branch name="XLXN_59">
            <wire x2="3216" y1="1872" y2="1872" x1="3136" />
            <wire x2="3216" y1="1584" y2="1872" x1="3216" />
            <wire x2="4016" y1="1584" y2="1584" x1="3216" />
            <wire x2="4016" y1="1584" y2="2064" x1="4016" />
            <wire x2="4016" y1="2064" y2="2064" x1="3968" />
        </branch>
        <branch name="XLXN_60">
            <wire x2="3360" y1="2064" y2="2064" x1="3136" />
            <wire x2="3360" y1="1872" y2="2064" x1="3360" />
            <wire x2="3584" y1="1872" y2="1872" x1="3360" />
        </branch>
        <branch name="XLXN_61">
            <wire x2="2800" y1="2064" y2="2064" x1="2736" />
            <wire x2="2736" y1="2064" y2="2256" x1="2736" />
            <wire x2="3264" y1="2256" y2="2256" x1="2736" />
            <wire x2="3264" y1="1808" y2="2256" x1="3264" />
            <wire x2="3584" y1="1808" y2="1808" x1="3264" />
        </branch>
        <branch name="XLXN_62(0:0)">
            <wire x2="3360" y1="1840" y2="1840" x1="3136" />
            <wire x2="3360" y1="1744" y2="1840" x1="3360" />
            <wire x2="3584" y1="1744" y2="1744" x1="3360" />
        </branch>
        <branch name="XLXN_63">
            <wire x2="2800" y1="1712" y2="1712" x1="2784" />
            <wire x2="2784" y1="1712" y2="2304" x1="2784" />
            <wire x2="3968" y1="2304" y2="2304" x1="2784" />
            <wire x2="3968" y1="2128" y2="2304" x1="3968" />
        </branch>
        <branch name="XLXN_66">
            <wire x2="4032" y1="1472" y2="1472" x1="2752" />
            <wire x2="4032" y1="1472" y2="2000" x1="4032" />
            <wire x2="2752" y1="1472" y2="1872" x1="2752" />
            <wire x2="2800" y1="1872" y2="1872" x1="2752" />
            <wire x2="4032" y1="2000" y2="2000" x1="3968" />
        </branch>
        <instance x="1600" y="1904" name="XLXI_1" orien="R0">
        </instance>
        <branch name="XLXN_68">
            <wire x2="2048" y1="1872" y2="1872" x1="1984" />
        </branch>
        <branch name="XLXN_70">
            <wire x2="2640" y1="1744" y2="1744" x1="2480" />
            <wire x2="2640" y1="1744" y2="1808" x1="2640" />
            <wire x2="2800" y1="1808" y2="1808" x1="2640" />
        </branch>
        <branch name="XLXN_74">
            <wire x2="1584" y1="1872" y2="1872" x1="1536" />
            <wire x2="1600" y1="1872" y2="1872" x1="1584" />
            <wire x2="1584" y1="1872" y2="2240" x1="1584" />
            <wire x2="3184" y1="2240" y2="2240" x1="1584" />
            <wire x2="3184" y1="1680" y2="2240" x1="3184" />
            <wire x2="3584" y1="1680" y2="1680" x1="3184" />
        </branch>
        <branch name="clk">
            <wire x2="1072" y1="2000" y2="2000" x1="1040" />
        </branch>
        <iomarker fontsize="28" x="1040" y="2000" name="clk" orien="R180" />
    </sheet>
</drawing>