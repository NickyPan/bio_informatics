# !/bin/bash
dir_path=`pwd`
dir_name=$(basename $dir_path)
now_date=`date "+%Y%m%d"`;

echo -e "下机数据统计见附件，地址 $dir_path/split" | mail -s "$dir_name下机数据报告-$now_date" -a ./Reports/html/HVW2WAFXX/all/all/all/laneBarcode.html xinchen.pan@we-health.vip,jingmin.yang@we-health.vip,lin.shen@we-health.vip,wentao.li@we-health.vip,xiaoliang.tian@we-health.vip,yujie.wang@we-health.vip,zhouxiu.yu@we-health.vip,yanan.li@we-health.vip,hui.xu@we-health.vip
