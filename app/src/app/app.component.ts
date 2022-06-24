import {Component, OnInit} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {PlatformDto} from "./platform/platform.dto";
import {DateTime} from "luxon";
import Config from "../../../configuration.json";

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {

  private backendUrl = Config.terraform_domain !== '' ?
    `https://${Config.terraform_subdomain_backend}.${Config.terraform_domain}` :
    Config.terraform_apigateway_url;
  public order = [
    'twitter',
    'medium',
    'revue',
    'dev',
    'hashnode',
    'stackoverflow',
    'reddit',
    'github',
    'hackernews',
  ]

  public filters = [
    {number: 4, unit: 'hour'},
    {number: 1, unit: 'day'},
    {number: 1, unit: 'week'},
    {number: 1, unit: 'month'}
  ];
  public selectedFilter = this.filters[1];

  // @ts-ignore
  public platforms: Record<string, PlatformDto> = {};

  constructor(private httpClient: HttpClient) {
  }

  getPlatforms() {
    if (!this.platforms) return [];
    return Object.values(this.platforms)
      .sort((a, b) => this.order.indexOf(b.name!) > this.order.indexOf(a.name!) ? -1 : 1)
  }

  ngOnInit(): void {
    this.reloadPlatformData()
  }

  reloadPlatformData() {
    const since = DateTime.utc()
      .minus({[this.selectedFilter.unit]: this.selectedFilter.number}).toFormat('yyyyLLdd-HHmmss');
    console.log(`Loading Data since ${since}`)
    this.httpClient.get(`${this.backendUrl}?since=${since}`)
      .toPromise().then((data: any) => this.platforms = data);
  }

}
