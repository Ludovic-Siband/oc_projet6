import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Olympic } from '../models/Olympic';

@Injectable({
  providedIn: 'root',
})
export class OlympicService {
  /**
   * JSON mock data location for local use.
   */
  private olympicUrl = './assets/mock/olympic.json';

  constructor(private http: HttpClient) {}

  /**
   * Fetch the list of olympic entries from the mock dataset.
   */
  getOlympics(): Observable<Array<Olympic>> {
    return this.http.get<Array<Olympic>>(this.olympicUrl).pipe(
      catchError((error, caught) => {
        console.error(error);
        return caught;
      })
    );
  }
}
