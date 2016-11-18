# THINPAD2
THINPAD version 2

#### RamBlock
###### Memory模块，其中只使用RAM1+UART，不适用RAM2，原因是RAM1和UART都可以由指示灯显示出来当前的状态，调试较为方便，现在的代码也不存在冲突
* DYP显示的是Memory内部的state状态机（现在port map的DYP1是左边的七段数码管）
* **主要包含以下几种操作**
  * 读取Instruction
    * `001`：PC上地址总线，OE拉低，DATA高阻，等待`011`
    * `011`：将DATA中读到的数据推到Ins端输出，拉高OE。
  * 读取Data
    * 输入ALU不为BF00/BF01【RAM】
      * `010`：ALU上地址总线，OE拉低，进入状态0，等待`100`
      * `100`：将数据总线上数据推到Output，拉高**Finish**
    * 输入ALU为BF00/BF01【串口】
      * `010`：进入状态1，等待`100`
      * `100`：等待DATA_READY拉高，RDN拉低读，进入状态2，把读到的数据放到Output，拉高**Finish**
  * 写Data
    * 输入ALU不为BF00/BF01【RAM】
      * `101`/`110`：ALU上地址总线，Reg上数据总线，WE拉低，进入状态0，等待`111`
      * `111`：拉高**Finish**
    * 输入ALU为BF00/BF01【串口】
      * `101`/`110`：Reg/DATA_READY暂存在**uart_buf**，进入状态1，等待`111`
      * `111`：uart_buf上数据总线，拉低WRN，进入状态2，等待TBRE拉高，进入状态3，等待TSRE拉高，拉高**Finish**
* 关于BOOT
  * 一开始Finish='0'，外部需要等待Finish提高到'1'才能开始正常运作，这段时间RamBlock向RAM1中进行初始化。
  * 0->1->2->0 循环写入，count用来控制最大写入条数（最后条为全1HALT指令）。
