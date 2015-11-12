//
//  LBRAcknowledgements_ViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/2/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRAcknowledgements_ViewController.h"
#import "NSString+ArrayWriter.h"

@interface LBRAcknowledgements_ViewController ()

@end

@implementation LBRAcknowledgements_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupLicensesDictionary];
//    self.title = @"Acknowledgments";
    self.title = @"Credits";
}

#pragma mark - === Licenses ===

-(void)setupLicensesDictionary
{
    NSMutableString *mutableAckString = [NSMutableString string];
    NSString *pod;
    NSString *license;

    pod = @"Special Thanks To:";
    license = @"My instructors Tim Clem and Joe Burgess, and TAs Jim, Tom, and Mark, and all my fellow students at The Flatiron School!\n\n******************";

    
    [mutableAckString appendString:pod];
    [mutableAckString appendString:license];
    
    pod = @"tl;dr\n";
    license = @"This software, as well as all the 3rd-party software under the hood, is under the MIT License, save Google, whose software is coverd by the Apache 2.0 license.\n==================================================\n\n\n";
    
    [mutableAckString appendString:pod];
    [mutableAckString appendString:license];
    
    pod = @"AFNetworking\n";
    license = @"Copyright (c) 2011–2015 Alamofire Software Foundation (http://alamofire.org/)\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n==================================================\n\n\n";
    
    [mutableAckString appendString:pod];
    [mutableAckString appendString:license];
    
    pod = @"Google API/SDK\n";
    license = @"Copyright (c) 2014 Google Inc.\nLicensed under the Apache License, Version 2.0 (the \"License\"). A copy of the License can be obtained at:\n\n  http://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\nSee the License for the specific language governing permissions and limitations under the License.\n\n==================================================\n\n\n";
    
    [mutableAckString appendString:pod];
    [mutableAckString appendString:license];
    
    pod = @"MTBBarcodeScanner\n";
    license = @"Copyright (c) 2014 Mike Buss <michaeltbuss@gmail.com>\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n==================================================\n\n\n";
    
    [mutableAckString appendString:pod];
    [mutableAckString appendString:license];

    
    pod = @"NYAlertViewController\n";
    license = @"Copyright (c) 2014 Nealon Young\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n==================================================\n\n\n";
    
    [mutableAckString appendString:pod];
    [mutableAckString appendString:license];
        //    [mutableAcknowledgments setObject:license forKey:pod];
    
    pod = @"LARSTorch\n";
    license = @"Copyright (c) 2010-2013 Lars Anderson, theonlylars\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n==================================================\n\n\n";
    
    [mutableAckString appendString:pod];
    [mutableAckString appendString:license];
    
    pod = @"AMRatingContrl";
    license = @"Copyright (c) 2012, Ameddi\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nThe Software is provided \"as is\", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the Software.";
    
    [mutableAckString appendString:pod];
    [mutableAckString appendString:license];
    
    pod = @"FlatIcon.com";
    license = @"A number of icons used in this app are with used with permission from www.FlatIcon.com; those icons are designed by 'FreePik.'";

    [mutableAckString appendString:pod];
    [mutableAckString appendString:license];

    self.acknowledgmentsTextView.textContainerInset = UIEdgeInsetsZero;
    self.acknowledgmentsTextView.text = [mutableAckString copy];
    
    
}

@end
