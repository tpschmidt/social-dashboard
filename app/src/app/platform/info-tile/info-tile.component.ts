import {Component, Input, OnInit} from '@angular/core';
import {DateTime} from "luxon";
import {ValueDto} from "./value.dto";

@Component({
  selector: 'app-info-tile',
  templateUrl: './info-tile.component.html',
  styleUrls: ['./info-tile.component.scss']
})
export class InfoTileComponent implements OnInit {

  @Input() prefix: string | undefined
  @Input() backgroundColor: string | undefined;
  @Input() chartColor: string | undefined;
  @Input() values: ValueDto[] = [];

  view: [number, number] = [300, 175];
  multi: any = [];

  // options
  legend = false;
  showLabels = true;
  animations = true;
  xAxis = false;
  yAxis = true;
  showYAxisLabel = false;
  showXAxisLabel = false;
  xAxisLabel = 'Day';
  yAxisLabel = 'Population';
  timeline = false;
  colorScheme: any = { domain: [] };
  trimYAxisTicks = true;
  autoScale = true;


  ngOnInit(): void {
    this.multi = [{
      "name": this.prefix,
      "series": this.values?.map(value => ({
        "name": value.timestamp.toFormat('yyyyLLdd-HHmmss'),
        "value": value.value
      }))
    }];
    this.colorScheme.domain = [this.chartColor];
  }

  getGrowth() {
    return this.getLatest().value - this.getOldest().value;
  }

  getLatest(): ValueDto {
    return this.values[this.values.length - 1];
  }

  getOldest(): ValueDto {
    return this.values[0];
  }

  isPositive() {
    return this.getGrowth() >= 0;
  }

  onSelect(data: any): void {
    console.log('Item clicked', JSON.parse(JSON.stringify(data)));
  }

  onActivate(data: any): void {
    console.log('Activate', JSON.parse(JSON.stringify(data)));
  }

  onDeactivate(data: any): void {
    console.log('Deactivate', JSON.parse(JSON.stringify(data)));
  }
}
