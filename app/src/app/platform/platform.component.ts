import {Component, Input, OnInit} from '@angular/core';
import {PlatformDto} from "./platform.dto";
import {DateTime} from 'luxon';
import {ValueDto} from "./info-tile/value.dto";


@Component({
  selector: 'app-platform',
  templateUrl: './platform.component.html',
  styleUrls: ['./platform.component.scss']
})
export class PlatformComponent implements OnInit {

  @Input() public platformDto: PlatformDto | undefined;
  public infoTiles: {
    prefix: string,
    values: ValueDto[],
    backgroundColor: string,
    chartColor: string
  }[] = [];

  private map: { [key: string]: any } = {
    followers: {emoji: '🙋‍♂️', color: 'bg-amber-600', chartColor: '#9DF265'},
    // reactions: {emoji: '👌', color: 'bg-green-600'},
    // posts: {emoji: '📝', color: 'bg-sky-600'},
    karma: {emoji: '🔮', color: 'bg-violet-600', chartColor: '#9DF265'},
    reputation: {emoji: '✨', color: 'bg-red-600', chartColor: '#9DF265'},
  };

  constructor() {
  }

  ngOnInit(): void {
    if (this.platformDto?.data?.length) {
      Object.keys(this.map).forEach(key => {
        const hasKey = this.platformDto?.data.find(d => !!(d as any)[key]);
        if (!hasKey) return
        this.infoTiles.push({
          prefix: `${key} ${this.map[key].emoji}`,
          values: this.platformDto?.data.map(d => {
            const value = Number((d as any)[key])
            const timestamp = d.timestamp;
            return ValueDto.of(value, timestamp!);
          })!,
          backgroundColor: this.map[key].color,
          chartColor: this.map[key].chartColor,
        });
      });
    }
  }

  getLastUpdate() {
    if (!this.platformDto?.data?.length) return '';
    const index = this.platformDto.data.length! - 1;
    return DateTime.fromFormat(this.platformDto.data[index].timestamp!, 'yyyyLLdd-HHmmss', { zone: 'utc' }).toRelative();
  }

}
