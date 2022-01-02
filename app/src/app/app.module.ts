import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { PlatformComponent } from './platform/platform.component';
import {HttpClientModule} from "@angular/common/http";
import { InfoTileComponent } from './platform/info-tile/info-tile.component';
import {AreaChartModule, LineChartModule} from "@swimlane/ngx-charts";

@NgModule({
  declarations: [
    AppComponent,
    PlatformComponent,
    InfoTileComponent
  ],
    imports: [
        BrowserModule,
        AppRoutingModule,
        HttpClientModule,
        LineChartModule,
        AreaChartModule
    ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
