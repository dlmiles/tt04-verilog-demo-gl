#!/bin/bash -e
#
#
#
basedir=$(pwd)
workdir=$(dirname "$0")
projectdir="$workdir/.."

test -n "$RUNDIR" 	|| RUNDIR="$GITHUB_WORK/runs"
test -n "$SDFDIR" 	|| SDFDIR="$RUNDIR/wokwi/results/final/sdf"
test -n "$TOPLEVEL"	|| TOPLEVEL="dut"

if ! test -d $RUNDIR
then
	echo "$0: Unable to setup RUNDIR: $RUNDIR"
	exit 1
fi
if ! test -d $SDFDIR
then
	echo "$0: Unable to setup SDFDIR: $SDFDIR"
	exit 1
fi

echo "RUNDIR=$RUNDIR"
echo "SDFDIR=$SDFDIR"
echo "TOPLEVEL=$TOPLEVEL"

# basename=tt_um_seven_segment_seconds.sdf
top_verilog_basename=$(find "$SDFDIR" -maxdepth 1 -type f -name "*.sdf" | sed -e 's#^.*sdf/##' -e 's#\.sdf$##' | sort | head -n1)
echo "top_verilog_basename=$top_verilog_basename"

if ! test -f "$SDFDIR/${top_verilog_basename}.sdf"
then
	echo "$0: Unable to setup top_verilog_basename: $top_verilog_basename"
	exit 1
fi

# min tt_um_seven_segment_seconds.Typical.sdf
# min tt_um_seven_segment_seconds.Fastest.sdf
# min tt_um_seven_segment_seconds.Slowest.sdf
# nom tt_um_seven_segment_seconds.Typical.sdf
# nom tt_um_seven_segment_seconds.Fastest.sdf
# nom tt_um_seven_segment_seconds.Slowest.sdf
# max tt_um_seven_segment_seconds.Typical.sdf
# max tt_um_seven_segment_seconds.Fastest.sdf
# max tt_um_seven_segment_seconds.Slowest.sdf
find $SDFDIR -mindepth 2 -type f -name "*.sdf" | sed -e 's#sdf/multicorner/##g' -e 's#/# #'

test -d "${projectdir}/src/sdf" || mkdir "${projectdir}/src/sdf"

# Delay Selection
for mtmspec in min nom max
do
	case "$mtmspec" in
	'min')	MTMSPEC=",\"minimum\""
		;;
	'nom')	MTMSPEC=",\"typical\""
		;;
	'max')	MTMSPEC=",\"maximum\""
		;;
	*)	MTMSPEC=","
		;;
	esac

	for corner in Typical Fastest Slowest
	do
		SDFFILE="\"${SDFDIR}/multicorner/${mtmspec}/${top_verilog_basename}.${corner}.sdf\""
		DUT=",${TOPLEVEL}"
		LOGFILE=",\"sdf_annotate_${mtmspec}_${corner}.log\""
		LOGFILE=","
		(
			echo "// autogenerated for cvc"
			echo "module sdf_annotate();"
			echo "    initial begin"
			echo "        \$sdf_annotate(${SDFFILE}${DUT}${LOGFILE}${MTMSPEC});"
			echo "    end"
			echo "endmodule"
		) > "${projectdir}/src/sdf/sdf_annotate_${mtmspec}_${corner}.v"

		echo "GENERATED: ${projectdir}/src/sdf/sdf_annotate_${mtmspec}_${corner}.v"
	done
done

if [ -f "${SDFDIR}/${top_verilog_basename}.sdf" ]
then
	SDFFILE="\"${SDFDIR}/${top_verilog_basename}.sdf\""
	DUT=",${TOPLEVEL}"
	LOGFILE=",\"sdf_annotate.log\""
	LOGFILE=","
	(
		echo "// autogenerated for cvc"
		echo "module sdf_annotate();"
		echo "    initial begin"
		echo "        \$sdf_annotate(${SDFFILE}${DUT}${LOGFILE}${MTMSPEC});"
		echo "    end"
		echo "endmodule"
	) > "${projectdir}/src/sdf/sdf_annotate.v"

	echo "GENERATED: ${projectdir}/src/sdf/sdf_annotate.v"
fi

