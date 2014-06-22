#!/bin/sh

# Script to download android source
# Autor: Kingsley Yau
# Email : KingsleyYau@gmail.com

echo ""
echo "#######################################"
echo "# Script to download android source"
echo "# Autor : Kingsley Yau"
echo "# Email : KingsleyYau@gmail.com"
echo "# Version : 1.0"
echo "# Date : 13th Jun,2014"
echo "#######################################"
echo ""

# 配置
# 下载路径
sourcePath=https://android.googlesource.com
# 版本
revision=$1
# 保存版本信息目录
manifestDir="manifest"
# 保存源码目录
sourceDir="source"
# 版本信息文件
defaultXML=default.xml

function get_string_length()
{
	length=`echo $1 | awk '{ print length($0) }'`
	echo $length
}

if [ -z "$revision" ];then
	revision="master"
fi
echo "# 需要下载版本为 : $revision"

if [ -d "$manifestDir" ];then
	if [ "`ls -A $manifestDir`" = "" ];then
		echo "# 开始下载版本文件..."
		git clone "https://android.googlesource.com/platform/$manifestDir"
	fi
else
	echo "# 开始下载版本文件..."
	git clone "https://android.googlesource.com/platform/$manifestDir"
fi

if [ -d "$manifestDir" ];then
	echo "# 开始下载版本文件 : $defaultXML 完成"
	cd "$manifestDir"
#	echo ""
#	echo "#######################################"
#	echo "# 所有版本tag:"
#	git tag
#	echo "#######################################"
#	echo ""
	echo "# 切换到版本 : $revision"
	git checkout $revision
	cd ..
fi

if [ -f "$manifestDir/$defaultXML" ];then
	echo "# 复制版本文件 $manifestDir/$defaultXML 到 $defaultXML"
	cp -f $manifestDir/$defaultXML $defaultXML
else
	echo "# 没有找到版本文件, 退出脚本"
	exit
fi

# 下载主干不需要参数
if [ "master" = $revision ];then
	revision=`echo ""`
else
	revision=`echo "-b $revision"`
fi

# 是否强制重新下载所有文件
if [ "-F" = "$2" ];then
	echo "# 强制重新下载所有源文件, 开始删除旧文件..."
	rm -rf $sourceDir
fi

echo ""
echo "# 开始下载安卓源码..."
mkdir -p $sourceDir
cd $sourceDir
echo "# 当前目录为 : `pwd`"
echo ""

downFinish=false
while read line; do
	# 读取注释符号
	key=`echo $line | awk -F "<!--" '{ print $2 }'`
	if [ ! -z "$key" ];then
		continue
	fi
	
	# 读取project path
	key=`echo $line | awk -F "project path=\"" '{ print $2 }'`
	if [ ! -z "$key" ];then
		project=`echo $key | awk -F "\"" '{ print $1 }'`
		if [ ! -z "$project" ];then
			# 读取name
			key=`echo $line | awk -F "name=\"" '{ print $2 }'`
			length=$(get_string_length $key)
			if [ ! -z "$key" ];then
				name=`echo $key | awk -F "\"" '{ print $1 }'`
				length=$(get_string_length $name)
				if [ ! -z "$name" ];then
					downFinish=false
					if [ -d $project ];then
						if [ "`ls -A $project`" = "" ];then
							echo "# 开始下载 $SourcePath/$name"
							git clone $sourcePath/$name $project $revision
						fi
					else
						echo "# 开始下载 $SourcePath/$name"
						git clone $sourcePath/$name $project $revision
					fi	
					
					if [ -d $project ];then
						echo "# 下载 $sourcePath/$name 到 $project 完成"
						downFinish=true
					else
						echo "# 下载 $sourcePath/$name 到 $project 失败"
						downFinish=false
						break
					fi
				fi
			fi
		fi
	else
		# 读取copyfile
		key=`echo $line | awk -F "copyfile src=\"" '{ print $2 }'`
		if [ ! -z "$key" ];then
			copyfile=`echo $key | awk -F "\"" '{ print $1 }'`
			if [ ! -z "$copyfile" ];then
				#echo "找到 copyfile = $copyfile"
				# 读取dest
				key=`echo $line | awk -F "dest=\"" '{ print $2 }'`
				if [ ! -z "$key" ];then
					dest=`echo $key | awk -F "\"" '{ print $1 }'`
					if [ ! -z "$dest" ];then
						cp $project/$copyfile $dest
						echo "# 移动 $project/$copyfile 到 $dest"
					fi
				fi
			fi
		fi
	fi
done < ../default.xml

if $downFinish;then
	echo ""
	echo "# Android源代码下载完成, 开始执行编译脚本..."
	echo ""
	
else
	echo ""
	echo "# Android源代码下载失败, 退出脚本"
	exit
fi
