说明

打包
1.命令:./version.sh imgname
  输入更改信息,信息会保存在commit文件夹对应的板名.
2.固件信息:所有的固件信息保存在commit文件夹,查找对应板名的文件版本信息格式如下:
  20181119-1313      kernel: xxxxxx      uboot: xxxxxx
   - commit
  xxxxxx(年月日)-xxxx(时分)     kernel:固件对应kernel_commit     uboot:固件对应uboot_commit
   - 简要更新信息


烧写
请使用固件内已经打包配套的工具进行烧写：
1.Androidtool:Windows
2.Upgrade_tool:Linux

注意:
1.Androidtool，默认分区配置为rk3399-ubuntu1804.cfg,如果要对Android进行分区烧写请右键倒入rk3399-Android81.cfg
2.同个固件类型升级是没有问题的，如果不同固件类型之间互相烧写可能会失败.解决方法:
  (1)使用打包自带的固件先擦除，后升级
  	如:ubuntu18.04 升级 Android8.1
  (2)如果方法(1)失败后，可以在Wiki上找到对应固件的烧写工具擦除，再用现在的工具升级

