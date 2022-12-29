import { HttpClient } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { DateTime } from 'luxon';
import Config from '../../../configuration.json';
import { PlatformDto } from './platform/platform.dto';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnInit {
  private backendUrl =
    Config.terraform_domain !== ''
      ? `https://${Config.terraform_subdomain_backend}.${Config.terraform_domain}`
      : Config.terraform_apigateway_url;
  public display = [
    'twitter',
    'convertkit',
    'hashnode',
    'github',
  ];

  public filters = [
    { number: 1, unit: 'day' },
    { number: 1, unit: 'week' },
    { number: 1, unit: 'month' },
    { number: 3, unit: 'months' },
    { number: 12, unit: 'months' },
  ];
  public selectedFilter = this.filters[0];
  public fetchInProgress = false;

  // @ts-ignore
  public platforms: Record<string, PlatformDto> = {};

  constructor(private httpClient: HttpClient) {}

  getPlatforms() {
    if (!this.platforms) return [];
    return Object.values(this.platforms).sort((a, b) =>
      this.display.indexOf(b.name!) > this.display.indexOf(a.name!) ? -1 : 1
    )
    .filter((platform) => this.display.includes(platform.name!));
  }

  ngOnInit(): void {
    this.reloadPlatformData();
    setInterval(() => this.reloadPlatformData(), 1000 * 60 * 5);
  }

  reloadPlatformData() {
    const since = DateTime.utc()
      .minus({ [this.selectedFilter.unit]: this.selectedFilter.number })
      .toFormat('yyyyLLdd-HHmmss');
    console.log(`Loading Data since ${since}`);
    this.httpClient
      .get(`${this.backendUrl}?since=${since}`)
      .toPromise()
      .then((data: any) => (this.platforms = data));
  }
}
