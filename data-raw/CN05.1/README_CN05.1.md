
  ※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※
  ※                                                                        ※
  ※                       CN05.1格点化观测数据集                          ※
  ※                              2016                                ※
  ※                  国家气候中心 气候变化室 吴佳                      ※
  ※                                                                        ※
  ※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※
  

【数据简介】：
  数据来源：	基于国家气象信息中心2400余全国国家级台站（基本、基准和一般站）的日观测数据
  区域范围：	69.75-140.25°E,14.75-55.25°N
  格点数：	283（东西方向）*163（南北方向）
  水平分辨率：0.25°*0.25°
  时间段：	1961年1月1日-2015年12月31日
  时间尺度：	日平均、月平均值
  要素：	平均气温、降水量、最高气温、最低气温、平均风速、相对湿度、蒸发(2013年：因后面缺测很多插值有问题)

【文件名和变量说明】：
◆文件名：数据文件名格式为：CN05.1_A_1961_2015_B_025x025.dat/ CN05.1_A_1961_2015_B_025x025.nc，数据描述文件格式为：CN05.1_A_1961_2015_B_025x025.ctl
          A为要素代码，B为时间尺度代码。
◆要素说明：Tm 	平均气温（单位：℃）
            Pre 	降水量（单位：mm/day））
            Tmax	日最高气温（单位：℃）
            Tmin	日最低气温（单位：℃）
            Evp	蒸发量（单位：mm/day）
            Win	平均风速（单位：m/s）
            Rhu	相对湿度（单位：%）

【文件存放格式说明】：
  存放格式为二进制/nc格式
  缺测值： -9999.
  数据大小：日平均数据每个变量为3.26GB，月平均数据每个变量109MB。

【引用说明】：
使用资料时，关于资料的说明和需要引用的文献为：
类似于Xu et al. (2009)，数据集CN05.1使用距平逼近法(anomaly approach)，由气候场和距平场分别插值后叠加得到(吴佳和高学杰, 2013)，但使用了中国境内~2400个台站的观测资料。
As did by Xu et al. (2009), the CN05.1 dataset is constructed by the “anomaly approach” during the interpolation but with more station observations (~2400) in China (Wu and Gao, 2013). In the “anomaly approach”, a gridded climatology is first calculated, and then a gridded daily anomaly is added to the climatology to obtain the final dataset.

## 参考文献References: 

1. Xu Y, Gao XJ, Shen Y, Xu CH, Shi Y, Giorgi F, 2009. A daily temperature dataset over China and its application in validating a RCM simulation. Advances in Atmospheric Sciences, 26(4), 763–772.

2.吴佳, 高学杰, 2013. 一套格点化的中国区域逐日观测资料及与其它资料的对比. 地球物理学报, 56(4): 1102-1111, doi: 10.6038g20130406   /// Wu J, Gao XJ, 2013, A gridded daily observation dataset over China region and comparison with the other datasets. Chinese Journal of Geophysics, 56(4): 1102-1111, doi: 10.6038g20130406(in Chinese with English abstract)

3. 风速引用:
1.	Wu Jia, Gao Xuejie, Giorgi Filippo, Chen Deliang. Changes of effective temperature and cold/hot days in late decades over China based on a high resolution gridded observation dataset. Int. J. Climatol, 37(s1):788–800. DOI: 10.1002/joc.5038.
