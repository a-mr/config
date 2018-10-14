{

gStyle->Reset();

// Turn off some borders
gStyle->SetCanvasBorderMode(0);
gStyle->SetFrameBorderMode(0);
gStyle->SetPadBorderMode(0);
gStyle->SetDrawBorder(0);
gStyle->SetCanvasBorderSize(0);
gStyle->SetFrameBorderSize(0);
gStyle->SetPadBorderSize(1);
gStyle->SetTitleBorderSize(0);

// Say it in black and white!
gStyle->SetAxisColor(1, "xyz");
gStyle->SetCanvasColor(0);
gStyle->SetFrameFillColor(0);
gStyle->SetFrameLineColor(1);
gStyle->SetHistFillColor(0);
gStyle->SetHistLineColor(1);
//gStyle->SetPadColor(1);
gStyle->SetPadColor(kWhite);
gStyle->SetStatColor(0);
gStyle->SetStatTextColor(1);
gStyle->SetTitleColor(1);
gStyle->SetTitleTextColor(1);
gStyle->SetLabelColor(1,"xyz");
// Show functions in red...
gStyle->SetFuncColor(2);

// 2d hists text
//gStyle->SetPaintTextFormat("4.3f");
gStyle->SetPaintTextFormat("3.4g");


// Set the size of the default canvas
// 600x500 looks almost square
gStyle->SetCanvasDefH(500);
gStyle->SetCanvasDefW(600);
gStyle->SetCanvasDefX(10);
gStyle->SetCanvasDefY(10);

// Fonts:  I use Helvetica, upright, normal
//         I sort of wish they had something like "HIGZ portable" of PAW
int style_label_font=42;
gStyle->SetLabelFont(style_label_font,"xyz");
gStyle->SetLabelSize(0.045,"xyz");
gStyle->SetLabelOffset(0.015,"xyz");
gStyle->SetStatFont(style_label_font);
gStyle->SetTitleFont(style_label_font,"xyz"); // axis titles
gStyle->SetTitleFont(style_label_font,"h"); // histogram title
gStyle->SetTitleSize(0.05,"xyz"); // axis titles
gStyle->SetTitleSize(0.05,"h"); // histogram title
gStyle->SetTitleOffset(1.1,"x");
gStyle->SetTitleOffset(1.2,"y");
gStyle->SetStripDecimals(kFALSE); // if we have 1.5 do not set 1.0 -> 1
gStyle->SetTitleX(0.12); // spot where histogram title goes
gStyle->SetTitleW(0.78); // width computed so that title is centered
TGaxis::SetMaxDigits(2); // restrict the number of digits in labels

// Set Line Widths
gStyle->SetFrameLineWidth(2);
gStyle->SetFuncWidth(1);
gStyle->SetHistLineWidth(1);

// Set all fill styles to be empty and line styles to be solid
gStyle->SetFrameFillStyle(0);
gStyle->SetHistFillStyle(1001);
gStyle->SetFrameLineStyle(0);
gStyle->SetHistLineStyle(0);
gStyle->SetTitleStyle(0);
gStyle->SetFuncStyle(1);

// Set margins -- I like to shift the plot a little up and to the
// right to make more room for axis labels
gStyle->SetPadTopMargin(0.08);
gStyle->SetPadBottomMargin(0.12);
gStyle->SetPadLeftMargin(0.14);
gStyle->SetPadRightMargin(0.1);

// Set Data/Stat/... and other options
gStyle->SetOptDate(0);
gStyle->SetDateX(0.01);
gStyle->SetDateY(0.01);
gStyle->SetOptFile(0);
gStyle->SetOptFit(111);
gStyle->SetOptLogx(0);
gStyle->SetOptLogy(0);
gStyle->SetOptLogz(0);
gStyle->SetOptStat(1111110);// no histogram title
gStyle->SetStatFormat("6.4f");
gStyle->SetFitFormat("6.4f");
gStyle->SetStatStyle(0); // hollow
//gStyle->SetStatStyle(1001); // filled
gStyle->SetStatBorderSize(0);
gStyle->SetStatW(0.16);
gStyle->SetStatH(0.125);
//gStyle->SetStatX(0.90);
//gStyle->SetStatY(0.90);
gStyle->SetStatX(1.0-gStyle->GetPadRightMargin()-0.02);
gStyle->SetStatY(1.0-gStyle->GetPadTopMargin()-0.02);
gStyle->SetOptTitle(1);
// Set tick marks and turn off grids
//gStyle->SetNdivisions(1005,"xyz");
gStyle->SetNdivisions(510,"xyz");
gStyle->SetPadTickX(1);
gStyle->SetPadTickY(1);
gStyle->SetTickLength(0.02,"xyz");
gStyle->SetPadGridX(0);
gStyle->SetPadGridY(0);

// no supressed zeroes!
gStyle->SetHistMinimumZero(kTRUE);


// Set paper size for life in the US
//gStyle->SetPaperSize(TStyle::kUSLetter);
// or europe
gStyle->SetPaperSize(TStyle::kA4);

// use a pretty palette for color plots
gStyle->SetPalette(1,0);

//gStyle->SetLabelColor(1,"xyz");
// Force this style on all histograms
gROOT->ForceStyle();

// load up uber libraries
//gSystem->Load("libCalDetSI.so");
//gSystem->Load("libUberDST.so");

/////////////  root/loon version dependent compilation //////////////////////
// this allows you to use multiple root versions on the same system
// without libraries constantly being recompiled.
TString dirname = gROOT->GetVersion();
dirname.ReplaceAll(".","_");
dirname.ReplaceAll("/","_");
dirname.Append("_libs");
TString appname(gApplication->Argv(0));
if(appname.Contains("loon")){
  appname="loon";
}
else appname="root";
appname+="_";
dirname.Prepend(appname);
dirname.Prepend("/tmp/root_build/"); // base dir for compliled macros
dirname.Prepend(gSystem->Getenv("HOME"));
cout<<"Setting build directory to: "<<dirname<<endl;
gSystem->mkdir(dirname.Data(),true); // make dir if it doesn't exist
gSystem->SetBuildDir(dirname);
cout<<"\033[1;31mCAUTION!!! CERN ROOT IS RUNNING NOW!!!\033[0m"<<endl;

///////////////////////////////////////////////////////////////////////////////

gSystem->Load("libMinuit2.so");

// make sure to include headers from my home area
gSystem->AddIncludePath("-I$HOME/macros");
//gSystem->AddIncludePath("-I$HOME/base_macros");

gStyle->SetPalette(1,0);

}


//{
//  gStyle->Reset();
////  gROOT->SetStyle("Plain");
////  gStyle->SetOptStat(1111111);
////  gStyle->SetOptFit(1111);
////  gStyle->SetPalette(1);
////  gStyle->SetTitleFont(22);
////  gStyle->SetTitleFontSize(0.05);
////  gStyle->SetLabelSize(0.03,"x");
////  gStyle->SetLabelSize(0.03,"y");
////  new TBrowser();
//TStyle* OKStyle = new  TStyle("OKStyle", "OK Default Style");
//
//  // Colors
//
//  //set the background color to white
//  OKStyle->SetFillColor(10);
//  OKStyle->SetFrameFillColor(10);
//  OKStyle->SetFrameFillStyle(0);
//  OKStyle->SetFillStyle(0);
//  OKStyle->SetCanvasColor(10);
//  OKStyle->SetPadColor(10);
//  OKStyle->SetTitleFillColor(0);
//  OKStyle->SetStatColor(10);
//
//  // Get rid of drop shadow on legends
//  // This doesn't seem to work.  Call SetBorderSize(1) directly on your TLegends
//  OKStyle->SetLegendBorderSize(1);
//
//  //don't put a colored frame around the plots
//  OKStyle->SetFrameBorderMode(0);
//  OKStyle->SetCanvasBorderMode(0);
//  OKStyle->SetPadBorderMode(0);
//
//  //use the primary color palette
//  OKStyle->SetPalette(1,0);
//
//  //set the default line color for a histogram to be black
//  OKStyle->SetHistLineColor(kBlack);
//
//  //set the default line color for a fit function to be red
//  OKStyle->SetFuncColor(kRed);
//
//  //make the axis labels black
//  OKStyle->SetLabelColor(kBlack,"xyz");
//
//  //set the default title color to be black
//  OKStyle->SetTitleColor(kBlack);
//
//  //set the margins
//  OKStyle->SetPadBottomMargin(0.15);
//  OKStyle->SetPadLeftMargin(0.15);
//  OKStyle->SetPadTopMargin(0.075);
//  OKStyle->SetPadRightMargin(0.15);
//
//  //set axis label and title text sizes
//  OKStyle->SetLabelSize(0.05,"xyz");
//  OKStyle->SetTitleSize(0.07,"xyz");
//  OKStyle->SetTitleOffset(0.9,"xyz");
//  OKStyle->SetStatFontSize(0.05);
//  OKStyle->SetTextSize(0.07);
//  OKStyle->SetTitleBorderSize(0);
//
//  //set line widths
//  OKStyle->SetHistLineWidth(2);
//  OKStyle->SetFrameLineWidth(2);
//  OKStyle->SetFuncWidth(2);
//
//  // Misc
//
//  //align the titles to be centered
//  //OKStyle->SetTextAlign(22);
//
//  //turn off xy grids
//  OKStyle->SetPadGridX(0);
//  OKStyle->SetPadGridY(0);
//
//  //set the tick mark style
//  OKStyle->SetPadTickX(1);
//  OKStyle->SetPadTickY(1);
//
//  //don't show the fit parameters in a box
//  OKStyle->SetOptFit(0000);
//
//  //set the default stats shown
//  OKStyle->SetOptStat("neimr");
//
//  //marker settings
//  OKStyle->SetMarkerStyle(8);
//  OKStyle->SetMarkerSize(0.7);
//
//  // Fonts
//  OKStyle->SetStatFont(12);
//  OKStyle->SetLabelFont(12,"xyz");
//  OKStyle->SetTitleFont(12,"xyz");
//  OKStyle->SetTextFont(12);
//
//  // Set the paper size for output
//  OKStyle->SetPaperSize(TStyle::kUSLetter);
//
//  //done
//  OKStyle->cd();
//
//  cout << "Using OKStyle" << endl;
//
//  new TBrowser();
//}
