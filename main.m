@import AVFoundation;
#import <CydiaSubstrate/CydiaSubstrate.h>
#import "silence.h"
#define SHOW_ALERTS
#define DURATION 50

void alert(NSString* message)
{
#ifdef SHOW_ALERTS
	Class AlertClass=NSClassFromString(@"SBDismissOnlyAlertItem");
	NSObject* alertItem=[[AlertClass alloc] initWithTitle:@"pods hack" body:message];
	[AlertClass activateAlertItem:alertItem];
	alertItem.release;
#endif
}

@interface PodsHack:NSObject

@property(retain) NSData* data;
@property(retain) NSMutableArray<AVAudioPlayer*>* players;
@property(assign) BOOL active;
@property(assign) NSTimer* timer;

@end

@implementation PodsHack

-(instancetype)init
{
	AVAudioSession* session=AVAudioSession.sharedInstance;
	[session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
	
	self.data=[NSData dataWithBytesNoCopy:silence_mp3 length:silence_mp3_len];
	self.players=NSMutableArray.alloc.init.autorelease;
	self.timer=[NSTimer scheduledTimerWithTimeInterval:DURATION target:self selector:@selector(refresh) userInfo:nil repeats:true];
	
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(connect:) name:@"BluetoothDeviceConnectSuccessNotification" object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(disconnect:) name:@"BluetoothDeviceDisconnectSuccessNotification" object:nil];
	
	return self;
}

-(void)connect:(NSNotification*)note
{
	if(self.active)
	{
		return;
	}
	self.active=true;
	self.timer.fire;
	
	alert(@"enable");
}

-(void)disconnect:(NSNotification*)note
{
	if(!self.active)
	{
		return;
	}
	self.active=false;
	self.timer.fire;
	
	alert(@"disable");
}

-(void)refresh
{
	if(!self.active)
	{
		self.players.removeAllObjects;
		return;
	}
	
	AVAudioPlayer* player=[AVAudioPlayer.alloc initWithData:self.data error:nil].autorelease;
	assert(player);
	player.play;
	
	[self.players addObject:player];

	if(self.players.count>2)
	{
		[self.players removeObjectAtIndex:0];
	}
}

+(void)load
{
	PodsHack.alloc.init;
}

@end