
#define true		1
#define false		0

#define STD_DELAY		300

#define HARDWARE_REV_OLD
//#define HARDWARE_REV_NEW

#if defined HARDWARE_REV_OLD
#define SUPPLY_5V0_FACTOR 	2.0
#define SUPPLY_3V3_FACTOR	1.30303030303030303
#define SUPPLY_2V5_FACTOR	1.0
#endif
#if defined HARDWARE_REV_NEW
#define SUPPLY_5V0_FACTOR 	2.446808510638297872
#define SUPPLY_3V3_FACTOR	1.702127659574468085
#define SUPPLY_2V5_FACTOR	1.212765957446808511
#endif
#define SUPPLY_1V2_FACTOR	1.0

int main(void);
